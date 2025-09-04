# vim: set filetype=sh:

# ===================================
# Work-Specific Aliases
# ===================================
alias m="mint "
alias mf="mint format"
alias mb="mint build"
alias mbc="mint build-cfg"
alias mun="mint undeploy"
alias mbd="mint deploy"

alias rfmt="rexec mint format"
alias rbld="rexec mint build"
alias rcfg="rexec mint build-cfg"
alias rundep="rexec mint undeploy"
alias rdep="rexec mint deploy"
alias topo="topology-v3 "
alias gos="go-status"

# ===================================
# ===================================
# Utility Aliases
# ===================================
alias h='history 0'
alias xx='exit'
alias c='clear'
alias r='exec zsh'
alias cp='cp -av'
alias md='mkdir -p'
alias hg='h | rg'
alias wh='which '
alias W='wc -l'
alias ks='ls' # typo-prone fallback

# ===================================
# Application Aliases
# ===================================
[[ $(command -v nvim) ]] && alias vim='nvim'
alias vi='nvim'
[[ -f ~/nvim-macos-arm64/bin/nvim ]] && alias nnvim='~/nvim-macos-arm64/bin/nvim'
[[ $(command -v rg) ]] && alias grep='rg '
alias G='rg '
[[ $(command -v zoxide) ]] && alias cd='z'
# [[ $(command -v bat) ]] && {
#   alias bat='bat --style=snip --color=always'
#   alias cat='bat'
#   alias less='bat -p'
# }
[[ $(command -v gh) ]] && {
  alias ghc='gh copilot explain '
  alias ghcs='gh copilot suggest '
}
[[ $(command -v tmuxinator) ]] && alias mux="tmuxinator "
# if command -v fd &>/dev/null; then
#   fd_bin=$(which fd)
#   alias fda="$fd_bin --unrestricted --hidden"
#   alias fd="fd --ignore-file ~/.global_gitignore"
# fi
[[ $(command -v dust) ]] && alias du='dust -prb'

# ===================================
# Git Aliases
# ===================================
alias g='git '
alias ga='git add '
alias gco='git co '
alias gcb='git cb '
alias gcom='git checkout master'
alias gcm='git commit -a -m '
alias gcma='git commit --amend '
alias gs='git status'
alias gb='git branch '
alias gba='git branch -a'

# Diff
alias gd='git diff'
alias gdf='git diff --name-status'
alias gsd='git show --pretty="" --name-status '

# Push/Pull
alias gpl='git pull'
alias gps='git push '

# Log/Reflog
alias gl="git log --graph --color=always --abbrev-commit --pretty=format:'%C(auto)%h%C(auto)%d %s %C(green)(%ar) %C(bold blue)[%al]'"
alias gla="git log --graph --all --color=always --abbrev-commit --pretty=format:'%C(auto)%h%C(auto)%d %s %C(green)(%ar) %C(bold blue)[%al]'"
alias grf='git reflog --date=local'

# Rebase
alias grb='git rebase '
alias grbi='git rebase -i '
alias grbm='git rebase master'
alias grbc='git rebase --continue '
alias grba='git rebase --abort '

# Reset/Revert
alias gdk='git restore '
alias grst='git reset '

# ===================================
# Other Tools
# ===================================
alias vsh='vagrant ssh'
alias vrel='vagrant reload'
alias dk='docker'
alias dkc='docker-compose'

# ===================================
# Misc + Shortcuts
# ===================================
alias zz='z -'
alias cz='chezmoi'
alias ccd='chezmoi cd'
alias mvim="NVIM_APPNAME=nvim-minimal nvim"
alias tvim="NVIM_APPNAME=lazyvim-test nvim"
# alias ssh='fssh'
alias s='fssh'
alias man='fman'
alias vims="nvim_conf_switcher"
alias tm='tmux_sessions'

# ===================================
# Functions
# ===================================

# ==== File Listing (eza or ls) ====

if command -v eza &>/dev/null; then
  unalias ls 2>/dev/null
  ls() {
    command eza -I '*pyc*' "${eza_params[@]}" "$@"
  }

  lsa() {
    ls --all "$@"
  }

  lt() {
    ls -T -L=3 "$@"
  }

  ll() {
    ls --header --long --sort=modified "$@"
  }

  l() {
    ll "$@"
  }

  lla() {
    ll --all "$@"
  }

  lS() {
    ll --sort=size "$@"
  }

  lSa() {
    lla --sort=size "$@"
  }

  llA() {
    command eza -lbhHigUmuSa "$@"
  }

  lsd() {
    ls -D "$@"
  }

  lsf() {
    ls -F "$@"
  }

  llf() {
    ll -F "$@"
  }

  lld() {
    ll -D "$@"
  }

  lsh() {
    get_hidden_files "$@"
  }

  llh() {
    get_hidden_files long "$@"
  }
fi

# ==== fd/find ====

if command -v fd &>/dev/null; then
  fd() {
    command fd --ignore-file "$HOME/.global_gitignore" "$@"
  }

  fda() {
    command fd --unrestricted --hidden "$@"
  }
fi

# ==== bat ====

if command -v bat &>/dev/null; then
  bat() {
    command bat --style=snip --color=always "$@"
  }

  unalias cat 2>/dev/null
  cat() {
    if [[ -t 1 ]]; then
      command bat --style=snip --color=always --paging=never "$@"
    else
      command bat --style=plain --color=never --paging=never "$@"
    fi
  }

  unalias less 2>/dev/null
  less() {
    command bat --style=snip --color=always -p "$@"
  }
fi

unalias gg 2>/dev/null
gg() {
  read -r theme bg_mode < <(get-theme)
  base="$HOME/.config/lazygit/config.yml"

  declare -A special_themes
  special_themes=(
    ["everforest"]=1
    ["gruvbox"]=1
  )

  if [[ -v special_themes["$theme"] ]]; then
    theme="${theme}-${bg_mode}"
  fi

  theme_cfg="$HOME/.config/lazygit/${theme}.yml"
  if [ -f "$theme_cfg" ]; then
    LG_CONFIG_FILE="$base,$theme_cfg" lazygit
  else
    LG_CONFIG_FILE="$base" lazygit
  fi
}
# ==== zshrc* edit  ====
ee() {
  $EDITOR ~/.zshrc ~/.zprofile ~/custom_config.zsh
}

# ===================================
# ZLE Widgets & Bindings
# ===================================

bind_widget() {
  local name=$1 key=$2
  zle -N "$name"
  bindkey -M emacs "$key" "$name"
  bindkey -M vicmd "$key" "$name"
  bindkey -M viins "$key" "$name"
}
# Go up a directory
zle -N cd_up_widget
bind_widget cd_up_widget '^[[1;3A'

# Tmux session switcher
zle -N tm_widget
bind_widget tm_widget '^[.'

# Expand alias or insert space
# expand_alias_or_space() {
#   zle _expand_alias
#   if [[ $LBUFFER[-1] == ' ' ]]; then
#     return
#   else
#     zle self-insert
#   fi
# }
zle -N expand_alias_or_space
# bindkey " " expand_alias_or_space  # optional

# Theme switcher
set-theme-widget() {
  set-theme
  zle reset-prompt
}
zle -N set-theme-widget
bind_widget set-theme-widget '^[>'

# ===================================
# Final Initialization
# ===================================
source "$HOME/fzf_config.zsh"
