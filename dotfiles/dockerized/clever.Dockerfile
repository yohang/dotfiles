ARG DEBIAN_VERSION=bookworm-slim

FROM debian:${DEBIAN_VERSION}

SHELL ["/bin/bash", "-e", "-u", "-x", "-o", "pipefail", "-c"]

ARG USER_ID=1000
ARG USER_NAME=1000

RUN apt update; \
    apt install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      curl \
      file \
      git \
      gnupg \
      ssh-client \
      sudo \
      vim; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://clever-tools.clever-cloud.com/gpg/cc-nexus-deb.public.gpg.key | gpg --dearmor -o /usr/share/keyrings/cc-nexus-deb.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/cc-nexus-deb.gpg] https://nexus.clever-cloud.com/repository/deb stable main" | tee -a /etc/apt/sources.list.d/clever-cloud.list; \
    apt update; \
    apt install clever-tools

RUN adduser --disabled-password --uid ${USER_ID} ${USER_NAME}; \
    echo "${USER_NAME}	ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME}

RUN echo $'#!/bin/sh \n\
set -e \n\
\n\
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then \n\
 set -- clever "$@" \n\
fi \n\
 \n\
exec "$@" \n\
 \n\
' > /usr/local/bin/docker-entrypoint; \
    chmod a+x /usr/local/bin/docker-entrypoint

USER ${USER_NAME}

WORKDIR /home/${USER_NAME}

ENTRYPOINT ["docker-entrypoint"]
CMD ["clever"]
