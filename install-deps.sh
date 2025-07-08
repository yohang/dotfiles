#!/usr/bin/env sh

sudo apt update
sudo apt install -y \
    build-essential \
    btop \
    ca-certificates \
    cmake \
    curl \
    htop \
    jq \
    gpg \
    vim \
    wget \
    zsh

curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash

# Docker install
sudo install -m 0755 -d /etc/apt/keyrings



if [ -n "$(lsb_release -i | grep Ubuntu)" ]; then
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

if [ -n "$(lsb_release -i | grep Debian)" ]; then
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo apt update

# Vim config
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_basic_vimrc.sh

if [ ! -d ~/.zpresto ]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  zsh -c 'setopt EXTENDED_GLOB; for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"; done'
  chsh -s /bin/zsh
fi

chezmoi apply
