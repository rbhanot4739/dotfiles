# vim:set ft=sh :

# =================================== Fzf config ===================================

local find_all_cmd="fd --ignore-file ~/.global_gitignore --follow ."
local find_files_cmd="$find_all_cmd --type file "
local find_dirs_cmd="$find_all_cmd --type directory "

local default_header_opts="--header-first --header-border=bottom --header 'Press ? to toggle preview'"
local default_binds='--bind "shift-tab:up,tab:down,ctrl-space:toggle,ctrl-a:toggle-all,ctrl-v:become(nvim {}),?:toggle-preview"'

local file_prev_opts="--preview-label='File Contents' --preview 'bat --style=snip --color always {}' --preview-window right:50%"
local file_binds='--bind "alt-i:reload([ ! -f /tmp/fzf_hidden ] && (fd -tf -u --hidden && touch /tmp/fzf_hidden) || (fd -tf && rm -f /tmp/fzf_hidden))"'
local file_opts="--border-label='Fuzzy Files' $file_prev_opts $file_binds"

local dir_prev_opts="--preview-label=' Directory Contents ' --preview 'eza $eza_params {}' --preview-window :down:20%:wrap"
local dir_binds='--bind "alt-i:reload([ ! -f /tmp/fzf_hidden ] && (fd -td -u --hidden && touch /tmp/fzf_hidden) || (fd -td && rm -f /tmp/fzf_hidden))"'
local dir_opts="--border-label='Fuzzy Directories' $dir_prev_opts $dir_binds"

export FZF_DEFAULT_OPTS="--style default --info=inline-right --height 60% --margin 1,2 --layout=reverse $default_header_opts --border rounded --multi --cycle $default_binds"

export FZF_DEFAULT_COMMAND="$find_all_cmd"

export FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# file search opts
export FZF_CTRL_T_COMMAND="$find_files_cmd"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS $file_opts"

# dir search opts
export FZF_ALT_C_COMMAND="$find_dirs_cmd"
export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS --walker-skip .git,node_modules,build $dir_opts"

export FZF_COMPLETION_TRIGGER=","

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
  cd) eval "fzf $dir_opts \"\$@\"" ;;
  export | unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
  # ssh)          fzf --preview 'dig {}'                   "$@" ;;
  man) fzf --preview 'tldr --color=always {} 2>/dev/null' "$@" ;;
  bat | cat) eval "fzf $file_opts \"\$@\"";;
  ls | eza) eval "fzf $file_opts \"\$@\"";;
  *) fzf "$@" ;;
  esac
}

_fzf_compgen_path() {
  [[ "$1" == "." ]] && eval "$find_all_cmd --strip-cwd-prefix=always" || eval "$find_all_cmd $1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  [[ "$1" == "." ]] && eval "$find_dirs_cmd --strip-cwd-prefix=always" || eval "$find_dirs_cmd $1"
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

  cmd="$find_dirs_cmd $1 | fzf $FZF_ALT_C_OPTS --select-1 --exit-0"
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
      cmd="$find_files_cmd $args | fzf $file_opts --select-1 --exit-0 +m"
      selected_files=$(eval $cmd)
    else
      echo "Arguments must of same type i.e. either all files or directories"
      return 1
    fi
  else
    cmd="$find_files_cmd | fzf $file_opts --select-1 --exit-0 +m"
    selected_files="$(eval $cmd)"
  fi

  [[ ! -z $selected_files ]] && add_to_zsh_history "${EDITOR} ${selected_files}" && ${EDITOR} "${selected_files}" || return 1
}

gbf() {
  local branch=$(git branch | fzf --bind "enter:accept-or-print-query" | tr -d ' ')
  git checkout $branch 2>/dev/null || git checkout -b $branch
}

gbfa() {
  git checkout $(git branch --all | fzf)
}

# custom hostname completion
__fzf_list_hosts() {
  # hosts=($(awk '/^Host / {host=$2} /^ *Hostname / {print host,",",$2}' ~/.ssh/config.custom))
  local hosts=($(awk '/^Host / {print $2}' ~/.ssh/config.custom))
  hosts+=($(awk '!/rdev/ && !/k8s/ && /^[[:alpha:]]/ {print $1}' ~/.ssh/known_hosts))
  echo $hosts | tr ' ' '\n' | sort -u
}

fssh() {
  # Fuzzy search through SSH hosts and establish SSH connection
  # Usage: fssh [hostname]
  # If hostname is provided, connects directly
  # Otherwise, opens fuzzy finder to select from available hosts
  
  local target_host
  
  if [[ $# -eq 1 ]]; then
    target_host="$1"
  else
    target_host="$(__fzf_list_hosts | fzf)" || return 0
  fi

  if [[ -z "$target_host" ]]; then
    return 0
  fi

  # Connect using SSH with proper terminal settings
  TERM=xterm-color ssh "$target_host"
}
alias ssh='fssh'

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
  selection=$(fd --type=d "vim" ~/.config --exec basename | fzf --prompt="Select config > " --height=~50% --border-label="  Neovim Config Switcher ")
  NVIM_APPNAME=$selection nvim $@
}
zle -N _fzf_complete
alias vims="_nvim_config_switcher"

tm() {
  # bash $HOME/scripts/tmux/manager.sh $@
  tmux_sessions $@
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
bindkey -M viins '' tm_widget

local fzf_theme=$(cat /tmp/theme 2>/dev/null || echo "$THEME")
source $HOME/fzf-themes/${fzf_theme}.sh
