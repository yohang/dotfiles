#!/usr/bin/env zsh

if [[ 1 -eq $DISABLE_DOCKERIZED ]]; then
  return
fi

source ${0:a:h}/functions.sh

alias czsh="dockerized_build_and_run common latest zsh"
alias zellij="dockerized_build_and_run common latest zellij"
