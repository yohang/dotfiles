#!/usr/bin/env zsh

if [[ 1 -eq $INSIDE_DOCKER ]]; then
  return
fi

COMMON_SCRIPT_DIRECTORY="${0:a:h}"
COMMON_IMAGE_PREFIX="ygiarelli/common"

function docker_common {
  COMMON_IMAGE_NAME="${COMMON_IMAGE_PREFIX}"

  if [ -z "$(docker image list -q "${COMMON_IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         -t "${COMMON_IMAGE_NAME}" \
         --target base \
         "${COMMON_SCRIPT_DIRECTORY}"
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to build Docker image ${COMMON_IMAGE_NAME}"

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
    "${COMMON_IMAGE_NAME}" \
    "${@[@]:1}"
}

clean_common_docker_images() {
  docker image list -q "${COMMON_IMAGE_PREFIX}:*" | xargs -r docker image rm -f
}

alias czsh="docker_common zsh"
alias zellij="docker_common zellij"
