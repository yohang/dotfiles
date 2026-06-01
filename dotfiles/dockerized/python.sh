#!/usr/bin/env zsh

if [[ 1 -eq $DISABLE_DOCKERIZED ]]; then
  return
fi

source ${0:a:h}/functions.sh

SUPPORTED_PYTHON_VERSIONS=(3.13 3.14 3.15)

for version in "${SUPPORTED_PYTHON_VERSIONS[@]}"; do
  alias "python${version}"="dockerized_build_and_run python ${version}"
done

alias http="python3.14 http"
alias httpie="python3.14 httpie"
alias poetry="python3.14 poetry"
