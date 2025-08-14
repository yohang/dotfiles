ARG COMPOSER_VERSION=2
ARG DEBIAN_VERSION=trixie
ARG VERSION=latest

#
#
# Base image for all langage specific images
FROM debian:${DEBIAN_VERSION} AS base

SHELL ["/bin/bash", "-e", "-u", "-x", "-o", "pipefail", "-c"]

ARG USER_ID=1000
ARG USER_NAME=user

# libbz2-dev libc6-dev libcurl4-openssl-dev libdb-dev libevent-dev libffi-dev libglib2.0-dev libmaxminddb-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool xz-utils zlib1g-dev

RUN apt update; \
    apt install -y --no-install-recommends \
      autoconf \
      automake \
      btop \
      ca-certificates \
      curl \
      file \
      g++ \
      gcc \
      gettext \
      git \
      htop \
      iotop \
      jq \
      locales-all \
      make \
      patch \
      screen \
      ssh-client \
      sudo \
      unzip \
      vim \
      wget \
      zsh \
    ; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*


RUN wget $(curl --dump-header - https://github.com/zellij-org/zellij/releases/latest 2>/dev/null | grep -i 'location: ' | awk '{print $2; }' | sed 's/tag/download/g' | rev | cut --complement -c-1 | rev)/zellij-x86_64-unknown-linux-musl.tar.gz; \
    tar -xvf zellij*.tar.gz; \
    chmod a+x zellij; \
    mv zellij /usr/local/bin/zellij; \
    rm zellij*.tar.gz

RUN adduser --disabled-password --uid ${USER_ID} ${USER_NAME}; \
    echo "${USER_NAME}	ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME};

USER ${USER_NAME}

WORKDIR /home/${USER_NAME}

ENV LANG=fr_FR.UTF-8 \
    LC_ALL=fr_FR.UTF-8 \
    INSIDE_DOCKER=1

ENTRYPOINT []
CMD []

#
#
# PHP Section
FROM composer:${COMPOSER_VERSION} AS composer_base
FROM php:${VERSION}-zts AS php_upstream
FROM base AS php

USER root

RUN apt update; \
    apt install -y --no-install-recommends libargon2-dev libcurl4-openssl-dev libonig-dev libreadline-dev libsodium-dev libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*

COPY --from=php_upstream /usr/local /usr/local

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini; \
    sed -i -E 's/memory_limit = \w+/memory_limit = -1/g' /usr/local/etc/php/php.ini

COPY --chmod=0755 --from=composer_base /usr/bin/composer /usr/local/bin/composer

RUN if [[ $(php -r 'echo PHP_VERSION_ID;') -ge 80200 ]]; then \
        curl "https://castor.jolicode.com/install" | bash; \
        mv /root/.local/bin/castor /usr/local/bin/castor; \
        chmod a+x /usr/local/bin/castor; \
    fi

USER ${USER_NAME}

ENTRYPOINT ["/usr/local/bin/docker-php-entrypoint"]

#
#
# Rust Section
FROM rust:${VERSION}-${DEBIAN_VERSION} AS rust_upstream
FROM base AS rust

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.88.0

USER root

COPY --from=rust_upstream /usr/local /usr/local

RUN cargo install --locked \
    tlrc

RUN echo $'#!/bin/sh \n\
set -e \n\
\n\
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then \n\
 set -- rustc "$@" \n\
fi \n\
 \n\
exec "$@" \n\
 \n\
' > /usr/local/bin/docker-entrypoint; \
    chmod a+x /usr/local/bin/docker-entrypoint

USER ${USER_NAME}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

#
#
# Go Section
FROM golang:${VERSION} AS go_upstream
FROM base AS go

ENV GOTOOLCHAIN=local
ENV GOPATH=/go
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USER root

RUN mkdir -p /go/bin /go/src; \
    chown -R ${USER_NAME}:${USER_NAME} /go

COPY --from=go_upstream /usr/local /usr/local

RUN echo $'#!/bin/sh \n\
set -e \n\
\n\
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then \n\
 set -- go "$@" \n\
fi \n\
 \n\
exec "$@" \n\
 \n\
' > /usr/local/bin/docker-entrypoint; \
    chmod a+x /usr/local/bin/docker-entrypoint

USER ${USER_NAME}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

#
#
# Node Section

FROM node:${VERSION} AS node_upstream
FROM base AS node

USER root
WORKDIR /root

COPY --from=node_upstream /usr/local /usr/local
RUN rm /usr/local/bin/yarn /usr/local/bin/yarnpkg; \
    corepack enable; \
    npm install -g \
    @google/gemini-cli

USER ${USER_NAME}

WORKDIR /home/${USER_NAME}

RUN sudo npx playwright install-deps

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]


#
#
# Python Section
FROM python:${VERSION} AS python_upstream
FROM base AS python

USER root

COPY --from=python_upstream /usr/local /usr/local

RUN pip install \
    httpie

RUN echo $'#!/bin/sh \n\
set -e \n\
\n\
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then \n\
 set -- python "$@" \n\
fi \n\
 \n\
exec "$@" \n\
 \n\
' > /usr/local/bin/docker-entrypoint; \
    chmod a+x /usr/local/bin/docker-entrypoint

USER ${USER_NAME}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
