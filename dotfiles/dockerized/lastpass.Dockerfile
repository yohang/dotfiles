ARG DEBIAN_VERSION=bookworm-slim

FROM debian:${DEBIAN_VERSION}

ARG LASTPASS_VERSION=v1.6.1

SHELL ["/bin/bash", "-e", "-u", "-x", "-o", "pipefail", "-c"]

ARG USER_ID=1000
ARG USER_NAME=1000

RUN apt update; \
    apt install -y --no-install-recommends \
      file \
      git \
      sudo \
      bash-completion \
      build-essential \
      cmake \
      libcurl4  \
      libcurl4-openssl-dev  \
      libssl-dev  \
      libxml2 \
      libxml2-dev  \
      libssl3 \
      pkg-config \
      ca-certificates \
      xclip; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app; \
    cd /app; \
    git clone --branch ${LASTPASS_VERSION} https://github.com/lastpass/lastpass-cli.git .; \
    make; \
    make install;

RUN adduser --disabled-password --uid ${USER_ID} ${USER_NAME}; \
    echo "${USER_NAME}	ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME}

USER ${USER_NAME}

WORKDIR /home/${USER_NAME}

ENTRYPOINT ["lpass"]
