ARG PHP_VERSION=8.4
ARG COMPOSER_VERSION=2

FROM composer:${COMPOSER_VERSION} AS composer_base

FROM php:${PHP_VERSION}-cli

SHELL ["/bin/bash", "-e", "-u", "-x", "-o", "pipefail", "-c"]

ARG USER_ID=1000
ARG USER_NAME=1000

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apt update; \
    apt install -y --no-install-recommends \
      file \
      gettext \
      git \
      ssh-client \
      sudo; \
    install-php-extensions apcu gd imagick intl opcache zip xdebug; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*

RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini; \
    sed -i -E 's/memory_limit = \w+/memory_limit = -1/g' /usr/local/etc/php/php.ini

COPY --chmod=0755 --from=composer_base /usr/bin/composer /usr/local/bin/composer

RUN curl "https://castor.jolicode.com/install" | bash; \
    mv /root/.local/bin/castor /usr/local/bin/castor; \
    chmod a+x /usr/local/bin/castor

RUN adduser --disabled-password --uid ${USER_ID} ${USER_NAME}; \
    echo "${USER_NAME}	ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME};

USER ${USER_NAME}

WORKDIR /home/${USER_NAME}
