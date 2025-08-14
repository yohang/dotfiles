#!/usr/bin/env zsh

if [[ 1 -eq $DISABLE_DOCKERIZED ]]; then
  return
fi

SUPPORTED_NODE_VERSIONS=(20 22 24)


for version in "${SUPPORTED_NODE_VERSIONS[@]}"; do
  alias "node${version}"="dockerized_build_and_run node ${version}"
  alias node="node${version}"
done

alias npm="node npm"
alias npx="node npx"
alias yarn="node yarn"
alias pnpm="node pnpm"
alias gemini="node gemini"
