#!/usr/bin/env zsh

if [[ 1 -eq $DISABLE_DOCKERIZED ]]; then
  return
fi

source ${0:a:h}/functions.sh

SUPPORTED_GO_VERSIONS=(1.24 1.25 1.26)

for version in "${SUPPORTED_GO_VERSIONS[@]}"; do
  alias "go${version}"="dockerized_build_and_run go ${version}"
done

alias stern="go1.26 stern"
