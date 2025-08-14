#!/usr/bin/env zsh

if [[ 1 -eq $INSIDE_DOCKER ]]; then
  return
fi

source ${0:a:h}/functions.sh

SUPPORTED_GO_VERSIONS=(1.24)

for version in "${SUPPORTED_GO_VERSIONS[@]}"; do
  alias "go${version}"="dockerized_build_and_run go ${version}"
  alias go="go${version}"
done
