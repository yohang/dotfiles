ARG PYTHON_VERSION=3.13

FROM python:${PYTHON_VERSION}

SHELL ["/bin/bash", "-e", "-u", "-x", "-o", "pipefail", "-c"]

ARG USER_ID=1000
ARG USER_NAME=1000

RUN apt update; \
    apt install -y --no-install-recommends \
      file \
      gettext \
      git \
      jq \
      ssh-client \
      sudo; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*

RUN pip install httpie

RUN adduser --disabled-password --uid ${USER_ID} ${USER_NAME}; \
    echo "${USER_NAME}	ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME};

USER ${USER_NAME}

WORKDIR /home/${USER_NAME}

