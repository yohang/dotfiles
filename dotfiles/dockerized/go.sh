#!/usr/bin/env zsh

SUPPORTED_GO_VERSIONS=(1.24)

GO_SCRIPT_DIRECTORY="${0:a:h}"
GO_IMAGE_PREFIX="ygiarelli/golang"

function docker_go {
  GO_IMAGE_NAME="${GO_IMAGE_PREFIX}:${1}"

  if [ -z "$(docker image list -q "${GO_IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg GO_VERSION="${1}" \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         -f "${GO_SCRIPT_DIRECTORY}/go.Dockerfile" \
         -t "${GO_IMAGE_NAME}" \
         "${GO_SCRIPT_DIRECTORY}"
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to build Docker image ${GO_IMAGE_NAME}"

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
    "${GO_IMAGE_NAME}" \
    "${@[@]:2}"
}

clean_go_docker_images() {
  docker image list -q "${GO_IMAGE_PREFIX}:*" | xargs -r docker image rm -f
}

for version in "${SUPPORTED_GO_VERSIONS[@]}"; do
  alias "go${version}"="docker_go ${version}"
  alias go="go${version}"
done
