#!/usr/bin/env zsh

SUPPORTED_PYTHON_VERSIONS=(3.13)

PYTHON_SCRIPT_DIRECTORY="${0:a:h}"
PYTHON_IMAGE_PREFIX="ygiarelli/python"

function docker_python {
  PYTHON_IMAGE_NAME="${PYTHON_IMAGE_PREFIX}:${1}"

  if [ -z "$(docker image list -q "${PYTHON_IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg PYTHON_VERSION="${1}" \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         -f "${PYTHON_SCRIPT_DIRECTORY}/python.Dockerfile" \
         -t "${PYTHON_IMAGE_NAME}" \
         "${PYTHON_SCRIPT_DIRECTORY}"
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to build Docker image ${PYTHON_IMAGE_NAME}"

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
    "${PYTHON_IMAGE_NAME}" \
    "${@[@]:2}"
}

clean_python_docker_images() {
  docker image list -q "${PYTHON_IMAGE_PREFIX}:*" | xargs -r docker image rm -f
}

for version in "${SUPPORTED_PYTHON_VERSIONS[@]}"; do
  alias "python${version}"="docker_python ${version}"
  alias python="python${version}"
done

alias pip="python pip"
alias http="python http"
alias httpie="python httpie"
