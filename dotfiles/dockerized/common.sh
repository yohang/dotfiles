#!/usr/bin/env zsh

if [[ 1 -eq $INSIDE_DOCKER ]]; then
  return
fi

source ${0:a:h}/functions.sh

alias czsh="dockerized_build_and_run base latest zsh"
alias zellij="dockerized_build_and_run base latest zellij"
