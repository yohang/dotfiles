#!/usr/bin/env zsh

if [[ 1 -eq $INSIDE_DOCKER ]]; then
  return
fi

SUPPORTED_PHP_VERSIONS=(7.4 8.0 8.1 8.2 8.3 8.4)

PHP_SCRIPT_DIRECTORY="${0:a:h}"
PHP_IMAGE_PREFIX="ygiarelli/php"

function docker_php {
  PHP_IMAGE_NAME="${PHP_IMAGE_PREFIX}:${1}"

  if [ -z "$(docker image list -q "${PHP_IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg PHP_VERSION="${1}" \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         --target php \
         -t "${PHP_IMAGE_NAME}" \
         "${PHP_SCRIPT_DIRECTORY}"
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to build Docker image ${PHP_IMAGE_NAME}"

    return 1
  fi

  EXTRA_ARGS=()
  if [[ "${PWD}" =~ ^"/home/" ]]; then
      EXTRA_ARGS=(${EXTRA_ARGS} -w "${PWD}")
  fi

  docker run -it --rm \
    -v /home:/home \
    --network host \
    ${EXTRA_ARGS} \
    "${PHP_IMAGE_NAME}" \
    "${@[@]:2}"
}

clean_php_docker_images() {
  docker image list -q "${PHP_IMAGE_PREFIX}:*" | xargs -r docker image rm -f
}

for version in "${SUPPORTED_PHP_VERSIONS[@]}"; do
  alias "php${version}"="docker_php ${version}"
  alias php="php${version}"
done

alias composer="php composer"
alias castor="php castor"
