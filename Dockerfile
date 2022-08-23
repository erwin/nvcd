FROM ghcr.io/void-linux/void-linux:latest-full-x86_64
# FROM ubuntu:latest

ARG USER_NAME
ARG USER_ID
ARG USER_SHELL
ARG GROUP_ID
ARG GROUP_NAME
ARG GIT_USER_NAME
ARG GIT_USER_EMAIL
ARG EXTRA_PACKAGES

#RUN echo "FOO is $foo"
#RUN baz="something" && echo $baz

#RUN SHELL_PATH=$(head -n 1 /etc/shells) &&\
#    useradd --shell $SHELL_PATH --uid 1000 foo

# TODO: use xrankmirror to grab the fastest one
RUN mkdir -p /etc/xbps.d/ && \
    echo "repository=https://void.webconverger.org/current/" > \
    /etc/xbps.d/00-repository-main.conf

RUN xbps-install -Sy -y
RUN xbps-install -u xbps -y
RUN xbps-install $USER_SHELL $EXTRA_PACKAGES \
  tini \
  neovim  lua-language-server \
  xclip wl-clipboard git nodejs tree-sitter-devel ripgrep \
  glibc-locales \
  base-devel -y

COPY libc-locales /etc/default/libc-locales

RUN xbps-reconfigure -f glibc-locales

#RUN npm install --no-color --no-update-notifier --no-fund --location=global \
#  tree-sitter

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
