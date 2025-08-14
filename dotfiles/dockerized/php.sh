#!/usr/bin/env zsh

if [[ 1 -eq $DISABLE_DOCKERIZED ]]; then
  return
fi

source ${0:a:h}/functions.sh

SUPPORTED_PHP_VERSIONS=(7.4 8.0 8.1 8.2 8.3 8.4)

for version in "${SUPPORTED_PHP_VERSIONS[@]}"; do
  alias "php${version}"="dockerized_build_and_run php ${version}"
  alias php="php${version}"
done

alias composer="php composer"
alias castor="php castor"
