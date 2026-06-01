#!/usr/bin/env zsh

if [[ 1 -eq $DISABLE_DOCKERIZED ]]; then
  return
fi

SUPPORTED_NODE_VERSIONS=(20 22 24 26)


for version in "${SUPPORTED_NODE_VERSIONS[@]}"; do
  alias "node${version}"="dockerized_build_and_run node ${version}"
  alias dnode="node${version}"
done

alias dnode="node26"
alias dnpm="node26 npm"
alias dnpx="node26 npx"
alias dyarn="node26 yarn"
alias dpnpm="node26 pnpm"
alias dgemini="node26 gemini"
