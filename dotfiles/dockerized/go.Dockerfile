ARG GO_VERSION=1.24

FROM golang:${GO_VERSION}

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
    rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --uid ${USER_ID} ${USER_NAME}; \
    echo "${USER_NAME}	ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME};

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

WORKDIR /home/${USER_NAME}

ENTRYPOINT ["docker-entrypoint"]
CMD ["go"]
