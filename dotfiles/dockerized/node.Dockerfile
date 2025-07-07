ARG NODE_VERSION=24

FROM node:${NODE_VERSION}-slim

SHELL ["/bin/bash", "-e", "-u", "-x", "-o", "pipefail", "-c"]

ARG USER_ID=1000
ARG USER_NAME=1000

RUN apt update; \
    apt install -y --no-install-recommends \
      file \
      gettext \
      git \
      ssh-client \
      sudo; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*; \
    corepack enable; \
    pnpm version

RUN adduser --disabled-password --uid ${USER_ID} ${USER_NAME}; \
    echo "${USER_NAME}	ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME};

USER ${USER_NAME}

WORKDIR /home/${USER_NAME}

RUN sudo npx playwright install-deps
