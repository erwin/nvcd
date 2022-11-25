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

#RUN SHELL_PATH=$(head -n 1 /etc/shells) &&\
#    useradd --shell $SHELL_PATH --uid 1000 foo

RUN mkdir -p /etc/xbps.d/ && \
    echo "repository=$MIRROR_URL" > \
    /etc/xbps.d/00-repository-main.conf

RUN echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> \
    /etc/sudoers

# apparently rust-analyzer requires:
# rustup component add rust-src
# but rustup must be installed manually
# 
# xbps-install \
#  rust-analyzer rust-std rustup rust cargo \
#  rustup rust-analyzer \

# Search for Void Packages at:
#   https://voidlinux.org/packages/

RUN xbps-install -S -y
RUN xbps-install -u xbps -y
RUN xbps-install $USER_SHELL $EXTRA_PACKAGES \
  tini \
  glibc-locales \
  xclip wl-clipboard \
  bash \
  curl \
  wget \
  sudo \
  wmii \
  git \
  ripgrep fd \
  base-devel \
  neovim  \
  tree-sitter-devel \
  \
  \
  bash shellcheck \
  lua lua-language-server luarocks \
  nodejs \
  go gopls  \
  clang libstdc++-devel \
  rust rust-analyzer rust-std cargo \
  ruby \
  php composer \
  python3 python3-pip \
  openjdk \
  -y

# tini: basic init process for docker containers
# glibc-locales: required to set the locale on command line and pass locale to neovim 
# xclip wl-clipboard: x11 clipboard and wayland clipboard utilities
# bash and curl: used to poll github/xbps for new neovim relases
# wget: optional complement to curl
# sudo: optional - helps inside shell to manually add additional packages
# wmii: supplies dependencies for winvim (libxrandr, libXft, libXinerama) I don't think needed for general users
# ripgrep and fd: better grep, and rust alternative to find - used by neovim
# base-devel: gcc and related build tools for compiling (could it be optional?)
# neovim: the whole point of this container
# tree-sitter-devel: required to build tree-sitter
# lua-language-server: sumneko/lua-language-server
# luarocks: Package management for Lua modules

# Note:
# lua-language-server, xclip, wl-clipboard, git, nodejs, tree-sitter-devel, ripgrep:
#   required to get correct config according to `nvim -c checkhealth`

COPY libc-locales /etc/default/libc-locales

RUN xbps-reconfigure -f glibc-locales

# Build Ruby LSP
# should it be installed via sudo?
RUN gem install sorbet
#RUN gem install solargraph ruby-lsp

# Install the HTML, CSS, JSON, and ESLINT Language Servers from VSCode
# and Bash Language Server https://github.com/bash-lsp/bash-language-server
RUN npm install --location=global --no-color --no-update-notifier --no-fund \
  vscode-langservers-extracted \
  bash-language-server

# Python PyRight Language Server
RUN pip install pyright

# Install Assembly Language Language Server
#https://github.com/bergercookie/asm-lsp
RUN cargo install asm-lsp

# PHP language server is https://github.com/phpactor/phpactor
# Install PHP Language Server with:
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=phpactor

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
