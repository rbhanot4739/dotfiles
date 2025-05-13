# vim: set filetype=sh:

#  =================================== Functions ===================================
get_hidden_files() {
	if [[ $1 == "long" ]]; then
		local params=('--git' '--group' '--group-directories-first' '--time-style=long-iso' '--color-scale=all' '--icons' '--header')
		if [[ $2 ]]; then
			OLDDIR=$(pwd)
			cd $2
			eza $params --group-directories-first -snew -dl .* 2>/dev/null
			cd $OLDDIR
		else
			eza $params --group-directories-first -snew -dl .* 2>/dev/null
		fi
	else
		if [[ $1 ]]; then
			OLDDIR=$(pwd)
			cd $1
			eza --group-directories-first -snew -d .* 2>/dev/null
			cd $OLDDIR
		else
			eza --group-directories-first -snew -d .* 2>/dev/null
		fi

	fi
}

debug_print() {
	if [[ "$DEBUG" -eq 1 ]]; then
		echo "DEBUG: $@"
	fi
}

cd_up_widget() {
	# echo "cd_up called"
	cd ..
	# zle reset-prompt
	zle accept-line
}

zle -N cd_up_widget
bindkey -M emacs '' cd_up_widget
bindkey -M vicmd '' cd_up_widget
bindkey -M viins '' cd_up_widget

#  =================================== Aliases ===================================

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

# create folowing aliases only if eza is installed else use ls
if [[ $(command -v eza) ]]; then
	alias ls='eza -I "*pyc*" $eza_params'
	alias lsa='ls --all'
	# alias l='ls --git-ignore'
	# print tree format
	alias lt='ls -T -L=3'
	alias ll='ls --header --long --sort=modified'
	alias l='ll'
	alias lla='ll --all'
	# sort by size
	alias lS='ll --sort=size'
	alias lSa='lla --sort=size'
	alias llA='eza -lbhHigUmuSa'
	alias lsd='ls -D'
	alias lsf='ls -F'
	alias llf='ll -F'
	alias lld='ll -D'
	alias lsh='get_hidden_files '
	alias llh='get_hidden_files long '
fi

# some utility aliases
alias dud='du -d 1 -hc 2> /dev/null | grep -Ev "\.$"|sort -h'
alias h='history 0'
# alias ssh='TERM=xterm-color ssh '
alias xx='exit'
alias ee='$EDITOR ~/.zshrc'
alias c='clear'
alias r='exec zsh'
alias cp='cp -av'
alias md='mkdir'
alias hg="h | rg"
alias wh='which '
alias W='wc -l'
alias wich='which '
alias wch='which '
[[ $(command -v nvim) ]] && alias vim='nvim'; alias vi='nvim'
[[ -f ~/nvim-macos-arm64/bin/nvim ]] && alias nnvim='~/nvim-macos-arm64/bin/nvim'
[[ $(command -v rg) ]] && alias grep='rg '; alias G='rg '
[[ $(command -v bat) ]] && alias bat='bat --color=always'; alias cat='bat'; alias less='bat -p'; alias L='bat -'
[[ $(command -v gh) ]] &&  alias ghc='gh copilot explain '; alias ghcs='gh copilot suggest '
[[ $(command -v tmuxinator) ]] && alias mux="tmuxinator "
[[ $(command -v fd) ]] && alias fd="fd --ignore-file ~/.global_gitignore"

# git aliases
alias gg='lazygit'
alias g="git "
alias ga='git add '
alias gco='git co '
alias gcb='git cb '
alias gcom='git checkout master'
alias gcm='git commit -a -m '
alias gcma='git commit --amend '
alias gs='git status'
alias gb='git branch '
alias gba='git branch -a'
# diff commands
alias gd='git diff'
alias gdf='git diff --name-status'
alias gsd='git show --pretty="" --name-status ' # show changes for a commit

# push/pull
alias gpl='git pull'
alias gps='git push '

# log/reflog
alias gl="git log --pretty=format:'%C(auto)%h%d%Creset %s %C(cyan) [%aN] %Creset %C(green)(%ci)%Creset'"
alias gla="git log --pretty=format:'%C(auto)%h%d%Creset %s %C(cyan) [%aN] %Creset %C(green)(%ci)%Creset' --graph --all"
# alias grf='git reflog '
alias grf='git reflog --date=local'

# rebase commmands
alias grb='git rebase '
alias grbi='git rebase -i '
alias grbm='git rebase master'
alias grbc='git rebase --continue '
alias grba='git rebase --abort '
# reset/revert
alias gdk='git restore '
alias grst='git reset '

# vagrant aliases
alias vsh='vagrant ssh'
alias vrel='vagrant reload'

alias dk=docker
alias dkc=docker-compose
alias zz='z -'
alias cm='chezmoi'
alias cmcd='chezmoi cd'
alias mvim="NVIM_APPNAME=nvim-minimal nvim"
alias tvim="NVIM_APPNAME=lazyvim-test nvim"

# typo prone aliases
alias ks="ls"


# =================================== Fzf config ===================================
# local catpuccino_colors="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=selected-bg:#45475a"
# local gruvbox_dark_colors="--color=bg+:#282828,bg:#282828,spinner:#fabd2f,hl:#fb4934 --color=fg:#ebdbb2,header:#fb4934,info:#b8bb26,pointer:#fabd2f --color=marker:#83a598,fg+:#ebdbb2,prompt:#b8bb26,hl+:#fb4934 --color=selected-bg:#3c3836"
# local fzf_colors=$gruvbox_colors
# local fzf_colors=$catpuccino_colors

local PREV_WIN_OPTS="--preview-window :down,20% --bind '?:change-preview-window(right|hidden|down)'  --header 'Press ? enable/toggle b/w preview modes' --header-label=Keymaps "
local FILE_PREV_OPTS="--preview-label='{}' --preview 'bat --style=snip --color always {}' $PREV_WIN_OPTS"
local DIR_PREV_OPTS="--preview-label=' Dir Contents ' --preview 'eza $eza_params {}' $PREV_WIN_OPTS"

# paths to ignore in addition to ~/.ignore
# local -a x_paths=("~/local-repo" "/export/apps" "*pyc")
# local xcludes=""
# for xpath in $x_paths; do
#   xcludes="$xcludes --exclude '$xpath' "
# done

local find_all_cmd="fd --ignore-file ~/.global_gitignore --follow . "
local find_files_cmd="$find_all_cmd --type file "
local find_dirs_cmd="$find_all_cmd --type directory "

local default_header_opts="--header-first --header-border=horizontal"
local default_binds='--bind=shift-tab:up,tab:down,ctrl-space:toggle,ctrl-a:toggle-all'
export FZF_DEFAULT_OPTS="--style default --info=inline-right --height 50% --margin 1,2 --layout=reverse $default_header_opts --border rounded --multi --cycle $default_binds" # Starts fzf in lower half of the screen taking 40% height

source $HOME/fzf-themes/${THEME}.sh
# if [[ $TMUX ]]; then
#   export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --tmux bottom,50%"
# fi
export FZF_DEFAULT_COMMAND="$find_all_cmd"

export FZF_CTRL_R_OPTS=""
export FZF_CTRL_T_COMMAND="$find_files_cmd"
export FZF_CTRL_T_OPTS="$FILE_PREV_OPTS"

export FZF_ALT_C_COMMAND="$find_dirs_cmd"
export FZF_ALT_C_OPTS="$DIR_PREV_OPTS"

export FZF_COMPLETION_TRIGGER="."
_fzf_compgen_path() {
  fd --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --follow --exclude ".git" . "$1"
}

# fuzzy searching functions

function rgf() {
  #!/usr/bin/env bash

  # Switch between Ripgrep launcher mode (CTRL-R) and fzf filtering mode (CTRL-F)
  rm -f /tmp/rg-fzf-{r,f}
  INITIAL_QUERY="${*:-}"
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload($RG_PREFIX {q})+unbind(ctrl-r)" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f)" \
    --bind "ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r)" \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --prompt '1. ripgrep> ' \
    --delimiter : \
    --header '╱ CTRL-R (ripgrep mode) ╱ CTRL-F (fzf mode) ╱' \
    --preview 'bat --style=snip --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind 'enter:become($EDITOR {1} +{2})'
  --style=full
}

add_to_zsh_history() {

  print -s $@
}

fcd() {
  # fuzzy jump to any directory
  # this is different from `z` as z only shows top few directories which are most accessed
 if  [[ $# -gt 1 ]] || [[ -f $1 ]]; then 
  echo "Only a single diurectory name can be provided"
  exit 
  fi

  cmd="$find_dirs_cmd $1 | fzf $DIR_PREV_OPTS --select-1 --exit-0"
  item=$(eval $cmd)
  [[ ! -z $item ]] && add_to_zsh_history "cd $item" && cd $item
}

v() {
  # Opens files or directories using the default editor.
  #
  # If arguments are provided, it checks if they are files or directories.
  # If all arguments are files, it opens them directly.
  # If all arguments are directories, it uses `fd` to find files in those directories and then pipe it through to  `fzf` to select files
  # If no arguments are provided, it uses `fzf` to select files from the current directory.
  #
  # Arguments:
  #   $@ - List of files or directories to open.
  #
  # Returns:
  #   0 if files are successfully opened, 1 otherwise.
  #
  # Example usage:
  #   v file1.txt file2.txt
  #   v /path/to/directory1 /path/to/directory2 /path/to/directory3 ...
  #   v
  #
  # Note: The function uses:
  #   - `fd` to find files
  #   - `fzf` for fuzzy file selection.
  #   - adds the opened files to the zsh history.
  #  - opens the files using the default editor.
  #

  local all_dirs=true
  local all_files=true

  for arg in "$@"; do
    if [[ -f "$arg" ]]; then
      all_dirs=false
    elif [[ -d "$arg" ]] || [[ -L "$arg" ]]; then
      all_files=false
    else 
      echo "Invalid argument: $arg doesn't exist"
      return 1
    fi
  done

  if [[ $# -gt 0 ]]; then
    local args=$@
    if $all_files; then
      ${EDITOR} $@
      return 0
    elif $all_dirs; then
      selected_files="$(eval $find_files_cmd $args | fzf $FILE_PREV_OPTS --select-1 --exit-0 +m)"
    else
      echo "Arguments must of same type i.e. either all files or directories"
      return 1
    fi
  else
    cmd="$find_files_cmd | fzf $FILE_PREV_OPTS --select-1 --exit-0 +m"
    selected_files="$(eval $cmd)"
  fi

  [[ ! -z $selected_files ]] && add_to_zsh_history "${EDITOR} ${selected_files}" && ${EDITOR} "${selected_files}" || return 1
}

gbf() {
  local branch=$(git branch | fzf --tmux left,30%,30% --bind "enter:accept-or-print-query" | tr -d ' ')
  git checkout $branch 2>/dev/null || git checkout -b $branch
}

gbfa() {
  git checkout $(git branch --all | fzf)
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
  cd) fzf --preview 'tree -C {} | head -200' "$@" ;;
  export | unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
  # ssh)          fzf --preview 'dig {}'                   "$@" ;;
  man) fzf --preview 'tldr --color=always {} 2>/dev/null' "$@" ;;
  cat | ls | eza) fzf --preview '[[ ! -d {} ]] && bat --color=always {}|| tree -C {}' "$@" ;;
  *) fzf "$@" ;;
  esac
}

# custom hostname completion
__fzf_list_hosts() {
  # hosts=($(awk '/^Host / {host=$2} /^ *Hostname / {print host,",",$2}' ~/.ssh/config.custom))
  local hosts=($(awk '/^Host / {print $2}' ~/.ssh/config.custom))
  hosts+=($(awk '!/rdev/ && !/k8s/ && /^[[:alpha:]]/ {print $1}' ~/.ssh/known_hosts))
  echo $hosts | tr ' ' '\n' | sort -u
}

fssh() {
  # fuzzy search through ssh hosts
  if [[ $# -eq 1 ]]; then
    ssh $1
  else
    __fzf_list_hosts | fzf --preview 'ssh -G {}' | xargs ssh
  fi
}
alias ssh='TERM=xterm-color fssh'

# man pages
__fzf_list_man_pages() {
  local paths="/usr/share/man /opt/homebrew/share/man $HOME/.local/share/devbox/global/default/.devbox/nix/profile/default/share/man"
  fd_cmd="fd -t f . --follow $paths"
  eval $fd_cmd | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}' | sort -u
}

# fuzzy search through man pages with tldr preview
fman() {
  if [[ $# -eq 1 ]]; then
    man $1
  else
__fzf_list_man_pages | fzf --preview 'tldr --color=always {} 2>/dev/null' | xargs man
  fi
}
alias man='fman'

_fzf_complete_man() {
  _fzf_complete +m -- "$@" < <(__fzf_list_man_pages)
}

_nvim_config_switcher() {
  fd --type=d "vim" ~/.config --exec basename | fzf --prompt="Select config > " --height=~50% --bind 'enter:become(NVIM_APPNAME={} nvim)' --border-label="  Neovim Config Switcher "
}
zle -N _fzf_complete
alias vims="_nvim_config_switcher"

tm() {
  bash $HOME/scripts/tmux/manager.sh $@
}
# `-s` binds key to a string command which is cool I guess
bindkey -s '^O' 'tm\n'

tm_widget() {
    BUFFER="tm"
    zle accept-line
}
zle -N tm_widget 
bindkey '' tm_widget
bindkey -M vicmd '' tm_widget
