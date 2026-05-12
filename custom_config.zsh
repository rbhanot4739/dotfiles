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

# Update installed packages (manual, explicit)
alias brew-up='brew update && brew upgrade && brew cleanup'

# Force-apply a theme locally (useful on remote SSH boxes when auto-sync missed)
# Usage: sync-theme          → re-apply current ~/.bg_mode
#        sync-theme light    → switch to light and apply
#        sync-theme dark     → switch to dark and apply
sync-theme() {
  local mode="${1:-}"
  if [[ -n "$mode" ]]; then
    echo "$mode" >~/.bg_mode
  fi
  if [[ -x ~/.config/themes/bin/theme-switch ]]; then
    ~/.config/themes/bin/theme-switch
  else
    echo "sync-theme: theme-switch not found at ~/.config/themes/bin/theme-switch" >&2
  fi
}

# Sync core CLI tools into chezmoi
brew-sync() {
  brew bundle dump \
    --file "$HOME/Brewfile" \
    --force \
    --formula \
    --no-vscode || return 1

  if [[ "$(uname -s)" == "Darwin" ]]; then
    brew bundle dump \
      --cask \
      --file "$HOME/Brewfile.darwin" \
      --force || return 1
  fi
}


# ===================================
# Application Aliases
# ===================================
[[ $(command -v nvim) ]] && alias vim='nvim'
alias vi='nvim'
[[ $(command -v rg) ]] && alias grep='rg '
alias G='rg '
[[ $(command -v gh) ]] && {
  alias ghc='gh copilot explain '
  alias ghcs='gh copilot suggest '
}
[[ $(command -v tmuxinator) ]] && alias mux="tmuxinator "
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
# _GIT_LOG_PRETTY_TAGGED, _GIT_LOG_PRETTY_BASE and _GIT_TAG_CANON_ERE live in
# ~/.config/fzf/common.zsh (loaded later in .zshrc) and are read at call time.
unalias gl 2>/dev/null
gl() {
  local -a log_cmd
  log_cmd=(
    git log --graph --decorate=short --color=always --abbrev-commit
    --pretty=format:"$_GIT_LOG_PRETTY_TAGGED"
  )

  # canonicalize_tag turns any tag carrying a semver suffix into vX.Y.Z so the
  # column stays consistent across DCL's parallel tag schemes (dcl/v3.0.61,
  # dcl_3.0.61, dcli/v3.0.61) and unrelated repos (ucm-pie-core-dcl_0.0.46).
  # Tags without a semver suffix pass through unchanged. Only commits whose %D
  # decoration actually contains a `tag:` ref are annotated — no nearest-tag
  # fallback, matching lazygit / `git log --decorate` semantics.
  # Regex passed through ENVIRON so awk -v's C-escape pass doesn't eat the
  # backslashes in `\.`. Same source as the sed regex in fzf gbf/gwt previews.
  local awk_prog='
    BEGIN {
      FS = "\037"
      esc = sprintf("%c", 27)
      tag_on = esc "[38;5;214m"
      tag_off = esc "[0m"
      canon_ere = ENVIRON["_GIT_TAG_CANON_ERE"]
    }
    function canonicalize_tag(t) {
      if (match(t, canon_ere))
        return "v" substr(t, RSTART, RLENGTH)
      return t
    }
    function first_tag(decor,    n, i, tok, parts) {
      n = split(decor, parts, ",")
      for (i = 1; i <= n; i++) {
        tok = parts[i]
        gsub(esc "\\[[0-9;]*m", "", tok)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", tok)
        if (index(tok, "tag: ") == 1) {
          return substr(tok, 6)
        }
      }
      return ""
    }
    {
      if (NF < 3) {
        print
        next
      }

      graph = $1
      hash = $2
      rest = $3
      decor = (NF >= 4 ? $4 : "")
      tag_disp = canonicalize_tag(first_tag(decor))

      if (tag_disp != "")
        printf "%s%s[%s]%s %s %s\n", graph, tag_on, tag_disp, tag_off, hash, rest
      else
        printf "%s%s %s\n", graph, hash, rest
    }
  '

  if [[ -t 1 ]]; then
    local pager_cmd="${PAGER:-less -R}"
    local -a pager_arr
    pager_arr=(${=pager_cmd})
    "${log_cmd[@]}" "$@" | _GIT_TAG_CANON_ERE="$_GIT_TAG_CANON_ERE" awk "$awk_prog" | "${pager_arr[@]}"
  else
    "${log_cmd[@]}" "$@" | _GIT_TAG_CANON_ERE="$_GIT_TAG_CANON_ERE" awk "$awk_prog"
  fi
}
gla() { git log --graph --all --color=always --abbrev-commit --pretty=format:"$_GIT_LOG_PRETTY_BASE" "$@"; }
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
alias cz='chezmoi'
alias ccd='chezmoi cd'
alias mvim="NVIM_APPNAME=nvim-minimal nvim"
alias tvim="NVIM_APPNAME=lazyvim-test nvim"
alias s='fssh'
alias man='fman'
alias vims="nvim_conf_switcher"
alias tm='tmux_sessions'
alias cc='claude'
alias ca='agent'
alias oc='opencode'
alias py="python3"
alias tssh='tmux-create-panes -s -c ssh'

# Ensure Cursor CLI keeps rich terminal rendering.
_cursor_cli() {
  TERM="${TERM:-xterm-256color}" NO_COLOR= FORCE_COLOR=1 command "$@"
}

agent() {
  _cursor_cli agent "$@"
}



# ===================================
# Functions
# ===================================

# ==== File Listing (eza or ls) ====

unalias ls 2>/dev/null

if command -v eza &>/dev/null; then
  ls() {
    command eza -I '*pyc*' ${eza_params:+"${eza_params[@]}"} "${@:-.}"
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
    # Check if output is to terminal
    if [[ -t 1 ]]; then
      # Check if any argument is a markdown file
      local has_markdown=false
      for arg in "$@"; do
        # Skip flags/options (starting with -)
        [[ "$arg" == -* ]] && continue
        # Check if file exists and has markdown extension
        if [[ -f "$arg" && "$arg" =~ \.(md|markdown|mdc)$ ]]; then
          has_markdown=true
          break
        fi
      done

      # Use glow for markdown, bat for everything else
      if [[ "$has_markdown" == true ]] && command -v glow &>/dev/null; then
        glow "$@"
      else
        command bat --style=snip --color=always --paging=never "$@"
      fi
    else
      # Non-interactive: use plain bat
      command bat --style=plain --color=never --paging=never "$@"
    fi
  }

  unalias less 2>/dev/null
  less() {
    command bat --style=snip --color=always -p "$@"
  }
fi

unalias glow 2>/dev/null
glow() {
  PAGER="less -R" command glow --style "$(cat ~/.bg_mode 2>/dev/null || echo dark)" "$@"
}

unalias gg 2>/dev/null
gg() {
  lazygit
}
# ==== zshrc* edit  ====
ee() {
  $EDITOR ~/.zshrc ~/.zprofile ~/custom_config.zsh ~/.config/fzf/config.zsh ~/.config/fzf/common.zsh ~/.config/fzf/tab.zsh
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
bind_widget cd_up_widget '^[[1;3A'

# Tmux session/pane switcher — mirrors tmux's M-space (no-prefix) binding
bind_widget tmux-switcher-widget '^[ '

# RGF launcher (Alt-/) across all keymaps.
rgf-widget() {
  zle -I
  rgf </dev/tty
  zle redisplay
}
bind_widget rgf-widget '^[/'
__bind_rgf_alt_slash() {
  bindkey -M emacs '^[/' rgf-widget
  bindkey -M vicmd '^[/' rgf-widget
  bindkey -M viins '^[/' rgf-widget
}
__bind_rgf_alt_slash
typeset -ag precmd_functions
[[ -z ${precmd_functions[(r)__bind_rgf_alt_slash]} ]] && precmd_functions+=(__bind_rgf_alt_slash)

# Theme switcher
set-theme-widget() {
  zle -I
  theme-list </dev/tty
  zle reset-prompt
}
bind_widget set-theme-widget '^[>'

