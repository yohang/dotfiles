#!/usr/bin/env zsh

KUBE_SCRIPT_DIRECTORY="${0:a:h}"

function docker_kube {
  IMAGE_NAME="ygiarelli/kube"

  if [ -z "$(docker image list -q "${IMAGE_NAME}" 2> /dev/null)" ]; then
     docker build \
         --build-arg USER_ID=${UID} \
         --build-arg USER_NAME="${USER}" \
         -f "${KUBE_SCRIPT_DIRECTORY}/kube.Dockerfile" \
         -t "${IMAGE_NAME}" \
         "${KUBE_SCRIPT_DIRECTORY}"
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
    "${@}"
}

clean_kube_docker_image() {
  docker image list -q "${IMAGE_NAME}:*" | xargs -r docker image rm -f
}

alias kubectl="docker_kube"
alias k9s="docker_kube k9s"
alias gcloud="docker_kube gcloud"
