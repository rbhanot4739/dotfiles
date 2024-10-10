#!/bin/bash

if [[ ! $(command -v devbox 2>/dev/null) ]]; then
  curl -fsSL https://get.jetify.com/devbox | bash
fi

eval "$(devbox global shellenv)"

# install packages
packages=("neovim" "ripgrep" "fzf" "fd" "lazygit" "zoxide" "eza" "delta" "bat" "tealdeer" "tmux" "tmuxinator" "direnv" "jq" "yq" "lua" "luajit")
for package in "${packages[@]}"; do
  devbox global add "$package"
done
