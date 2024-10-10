#!/bin/bash

if [[ ! $(command -v devbox 2>/dev/null) ]]; then
  curl -fsSL https://get.jetify.com/devbox | bash
fi

eval "$(devbox global shellenv)"

# install packages
packages=("neovim" "ripgrep" "fzf" "fd" "lazygit" "zoxide" "eza" "delta" "bat" "tealdeer" "tmux" "tmuxinator" "direnv" "jq" "yq" "sqlite" "lua" "luajit" "luarocks")
for package in "${packages[@]}"; do
  devbox global add "$package"
done

if [[ -f /export/apps/python/3.10/bin/python3 ]]; then
	/export/apps/python/3.10/bin/python3 -m venv $HOME/.nvim-env
	$HOME/.nvim-env/bin/python -m pip install neovim
fi

if [[ ! -d $HOME/powerlevel10k ]]; then
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
fi	
