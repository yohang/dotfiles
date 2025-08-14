#!/usr/bin/env zsh

if [[ 1 -eq $INSIDE_DOCKER ]]; then
  return
fi

SUPPORTED_NODE_VERSIONS=(20 22 24)

NODE_SCRIPT_DIRECTORY="${0:a:h}"
NODE_IMAGE_PREFIX="ygiarelli/node"

function docker_node {
  NODE_IMAGE_NAME="${NODE_IMAGE_PREFIX}:${1}"

  if [ -z "$(docker image list -q "${NODE_IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg VERSION="${1}" \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         --target node \
         -t "${NODE_IMAGE_NAME}" \
         "${NODE_SCRIPT_DIRECTORY}"
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to build Docker image ${NODE_IMAGE_NAME}"

    return 1
  fi

  EXTRA_ARGS=()
  if [[ "${PWD}" =~ ^"/home/" ]]; then
      EXTRA_ARGS=(${EXTRA_ARGS} -w "${PWD}")
  fi

  docker run -it --rm \
    -v /home:/home \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY \
    -e GEMINI_API_KEY \
    --network host \
    --privileged \
    ${EXTRA_ARGS} \
    "${NODE_IMAGE_NAME}" \
    "${@[@]:2}"
}

clean_node_docker_images() {
  docker image list -q "${NODE_IMAGE_PREFIX}:*" | xargs -r docker image rm -f
}

for version in "${SUPPORTED_NODE_VERSIONS[@]}"; do
  alias "node${version}"="docker_node ${version}"
  alias node="node${version}"
done

alias npm="node npm"
alias npx="node npx"
alias yarn="node yarn"
alias pnpm="node pnpm"
alias gemini="node gemini"
