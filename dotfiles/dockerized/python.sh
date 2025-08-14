#!/usr/bin/env zsh

if [[ 1 -eq $DISABLE_DOCKERIZED ]]; then
  return
fi

source ${0:a:h}/functions.sh

SUPPORTED_PYTHON_VERSIONS=(3.13)

for version in "${SUPPORTED_PYTHON_VERSIONS[@]}"; do
  alias "python${version}"="dockerized_build_and_run python ${version}"
  alias python="python${version}"
done

alias pip="python pip"
alias http="python http"
alias httpie="python httpie"
