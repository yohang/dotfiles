#!/usr/bin/env zsh

if [[ 1 -eq $DISABLE_DOCKERIZED ]]; then
  return
fi

source ${0:a:h}/functions.sh

alias browsh="dockerized_build_and_run browser latest browsh"
alias lynx="dockerized_build_and_run browser latest lynx"
alias w3m="dockerized_build_and_run browser latest w3m"
alias docker-firefox="dockerized_build_and_run browser latest firefox"
alias docker-chromium="dockerized_build_and_run browser latest chromium"
alias docker-chromedriver="dockerized_build_and_run browser latest chromedriver"
