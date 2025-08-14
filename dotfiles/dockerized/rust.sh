#!/usr/bin/env zsh

if [[ 1 -eq $DISABLE_DOCKERIZED ]]; then
  return
fi

SUPPORTED_RUST_VERSIONS=(1.88)

for version in "${SUPPORTED_RUST_VERSIONS[@]}"; do
  alias "rust${version}"="dockerized_build_and_run rust ${version}"
  alias rust="rust${version}"
done

alias rustc="rust rustc"
alias cargo="rust cargo"
alias tldr="rust tldr"
