#!/usr/bin/env zsh

SUPPORTED_RUST_VERSIONS=(1.88)

RUST_SCRIPT_DIRECTORY="${0:a:h}"
RUST_IMAGE_PREFIX="ygiarelli/rust"

function docker_rust {
  RUST_IMAGE_NAME="${RUST_IMAGE_PREFIX}:${1}-cli"

  if [ -z "$(docker image list -q "${RUST_IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg RUST_VERSION="${1}" \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         -f "${RUST_SCRIPT_DIRECTORY}/rust.Dockerfile" \
         -t "${RUST_IMAGE_NAME}" \
         "${RUST_SCRIPT_DIRECTORY}"
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to build Docker image ${RUST_IMAGE_NAME}"

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
    "${RUST_IMAGE_NAME}" \
    "${@[@]:2}"
}

clean_rust_docker_images() {
  docker image list -q "${RUST_IMAGE_PREFIX}:*" | xargs -r docker image rm -f
}

for version in "${SUPPORTED_RUST_VERSIONS[@]}"; do
  alias "rust${version}"="docker_rust ${version}"
  alias rust="rust${version}"
done

alias cargo="rust cargo"
alias tldr="rust tldr"
