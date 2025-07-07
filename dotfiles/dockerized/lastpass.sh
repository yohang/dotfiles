#!/usr/bin/env zsh

SCRIPT_DIRECTORY="${0:a:h}"
IMAGE_NAME="ygiarelli/lastpass-cli"

function docker_lastpass {
  if [ -z "$(docker image list -q "${IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         -f "${SCRIPT_DIRECTORY}/lastpass.Dockerfile" \
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
    ${EXTRA_ARGS} \
    "${IMAGE_NAME}" \
    "${@}"
}

clean_lastpass_docker_image() {
  docker image list -q "${IMAGE_NAME}:*" | xargs -r docker image rm -f
}

alias lpass=docker_lastpass
