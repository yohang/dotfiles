#!/usr/bin/env zsh

DOCKERIZED_DOCKERFILE_DIRECTORY="${0:a:h}"

function dockerized_build_and_run {
  IMAGE_PREFIX="ygiarelli/${1}"
  IMAGE_NAME="${IMAGE_PREFIX}:${2}"

  if [ -z "$(docker image list -q "${IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg VERSION="${2}" \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         -t "${IMAGE_NAME}" \
         --target ${1} \
         ${DOCKERIZED_DOCKERFILE_DIRECTORY}
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
    "${@[@]:3}"
}

dockerized_clean() {
  IMAGE_PREFIX="ygiarelli/${1}"

  docker image list -q "${IMAGE_PREFIX}:*" | xargs -r docker image rm -f
}
