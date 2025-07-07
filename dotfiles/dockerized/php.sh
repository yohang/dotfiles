#!/usr/bin/env zsh

SUPPORTED_PHP_VERSIONS=(7.4 8.0 8.1 8.2 8.3 8.4)

SCRIPT_DIRECTORY="${0:a:h}"
IMAGE_PREFIX="ygiarelli/php"

function docker_php {
  IMAGE_NAME="${IMAGE_PREFIX}:${1}-cli"

  if [ -z "$(docker image list -q "${IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg PHP_VERSION="${1}" \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         -f "${SCRIPT_DIRECTORY}/php.Dockerfile" \
         -t "${IMAGE_NAME}" \
         "${SCRIPT_DIRECTORY}"
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to build Docker image ${IMAGE_NAME}"

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
    "${IMAGE_NAME}" \
    "${@[@]:2}"
}

clean_php_docker_images() {
  docker image list -q "${IMAGE_PREFIX}:*" | xargs -r docker image rm -f
}

for version in "${SUPPORTED_PHP_VERSIONS[@]}"; do
  alias "php${version}"="docker_php ${version}"
  alias php="php${version}"
done

alias composer="php composer"
