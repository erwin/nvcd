FROM ghcr.io/void-linux/void-linux:latest-full-x86_64
# FROM ubuntu:latest

ARG USER_NAME
ARG USER_ID
ARG USER_SHELL
ARG GROUP_ID
ARG GROUP_NAME
ARG GIT_USER_NAME
ARG GIT_USER_EMAIL
ARG MIRROR_URL
ARG EXTRA_PACKAGES

#RUN echo "FOO is $foo"
#RUN baz="something" && echo $baz

#RUN SHELL_PATH=$(head -n 1 /etc/shells) &&\
#    useradd --shell $SHELL_PATH --uid 1000 foo

RUN mkdir -p /etc/xbps.d/ && \
    echo "repository=$MIRROR_URL" > \
    /etc/xbps.d/00-repository-main.conf

RUN xbps-install -Sy -y
RUN xbps-install -u xbps -y
RUN xbps-install $USER_SHELL $EXTRA_PACKAGES \
  tini \
  glibc-locales \
  neovim  lua-language-server \
  xclip wl-clipboard git nodejs tree-sitter-devel ripgrep \
  bash curl \
  wmii \
  base-devel -y

# tini: basic init process for docker containers
# bash and curl: used to poll github/xbps for new neovim relases
# glibc-locales: required to set the locale on command line and to give neovim 
# neovim: the whole point of this container
# lua-language-server, xclip, wl-clipboard, git, nodejs, tree-sitter-devel, ripgrep:
#   required to get correct config according to `nvim -c checkhealth`

COPY libc-locales /etc/default/libc-locales

RUN xbps-reconfigure -f glibc-locales

#RUN npm install --no-color --no-update-notifier --no-fund --location=global \
#  tree-sitter

# TODO: does this work for every possible sudo user?
RUN shell=$(grep -E -m 1 \.\*\\b$USER_SHELL\\b /etc/shells) && \
    echo "DUMP: $shell $USER_ID:$GROUP_ID $USER_NAME:$GROUP_NAME" && \
    groupadd --gid $GROUP_ID $GROUP_NAME && \
    useradd --shell $shell --uid $USER_ID --gid $GROUP_ID $USER_NAME

# set git config options for user
RUN if [ ! -z "$GIT_USER_NAME" ] && [ ! -z "$GIT_USER_EMAIL" ]; then \
      git config --global user.name "$GIT_USER_NAME"; \
      git config --global user.email "$GIT_USER_EMAIL"; \
    fi

ENTRYPOINT ["/bin/nvim"]
