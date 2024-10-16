#!/bin/bash

#
if [[ ! $(command -v devbox 2>/dev/null) ]]; then
  curl -fsSL https://get.jetify.com/devbox | bash
fi

# install packages
#packages=("neovim" "ripgrep" "fd" "lazygit" "zoxide" "eza" "delta" "bat" "tealdeer" "tmux" "tmuxinator" "direnv" "jq" "yq" "sqlite" "lua" "luajit" "luarocks")
#for package in "${packages[@]}"; do
#  devbox global add "$package"
#done

eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r 2>/dev/null
# cp devbox.json ~/.local/share/devbox/global/default/
# eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r 2>/dev/null

if [[ ! -d $HOME/.nvim-env ]]; then
  if [[ -f /export/apps/python/3.10/bin/python3 ]]; then
    /export/apps/python/3.10/bin/python3 -m venv "$HOME"/.nvim-env
    "$HOME"/.nvim-env/bin/python -m pip install neovim
  fi
fi

setup_shell() {

  # install powerlevel10k
  if [[ ! -d $HOME/powerlevel10k ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  fi

  # install zsh plugins
  PLUGIN_DIR="$HOME/.zsh/plugins"
  if [[ ! -d "$PLUGIN_DIR" ]]; then
    mkdir -p "$PLUGIN_DIR"
  fi

  PLUGINS=(
    zdharma-continuum/fast-syntax-highlighting
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-completions
    zsh-users/zsh-history-substring-search
    Aloxaf/fzf-tab
    jeffreytse/zsh-vi-mode
  )
  for plugin in "${PLUGINS[@]}"; do
    local plugin_name=$(basename "$plugin")
    local plugin_path="${PLUGIN_DIR}/$plugin_name"
    if [[ ! -d "$plugin_path" ]]; then
      git clone https://github.com/"$plugin" "$plugin_path"
    fi
  done
}
setup_shell
