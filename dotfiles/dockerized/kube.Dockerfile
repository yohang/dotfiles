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
      jq \
      sudo \
      vim \
      wget; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; \
    wget -qO- 'https://api.github.com/repos/derailed/k9s/releases/latest' | jq -r '.assets[] | select(.name | match("Linux_amd64.tar.gz")) | .browser_download_url' | grep -v sbom | xargs wget -qO- | tar -xzf -; \
    mv k9s /usr/local/bin/k9s; \
    chmod a+x /usr/local/bin/k9s

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg; \
    apt update; \
    apt install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --uid ${USER_ID} ${USER_NAME}; \
    echo "${USER_NAME}	ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME}

RUN echo $'#!/bin/sh \n\
set -e \n\
\n\
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then \n\
 set -- kubectl "$@" \n\
fi \n\
 \n\
exec "$@" \n\
 \n\
' > /usr/local/bin/docker-entrypoint; \
    chmod a+x /usr/local/bin/docker-entrypoint

USER ${USER_NAME}

ENV TERM=xterm-256color
ENV KUBE_EDITOR=vim

WORKDIR /home/${USER_NAME}

ENTRYPOINT ["docker-entrypoint"]
CMD ["kubectl"]
