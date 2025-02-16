# vim: ft=sh:
#
# =================================== Fzf config ===================================

local prev_win_opts="--preview-window :hidden --bind '?:change-preview-window(right|down|right,70%|hidden)' --header-first --header 'Press ? enable/toggle b/w preview modes'"
# paths to ignore in addition to ~/.ignore
local -a x_paths=("~/local-repo")
local xcludes=""
for xpath in $x_paths; do
  xcludes="$xcludes --exclude '$xpath' "
done
local find_all_cmd="fd --follow . $xcludes "
local find_files_cmd="$find_all_cmd --type file "
local find_dirs_cmd="$find_all_cmd --type directory "

# local catpuccino_colors="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=selected-bg:#45475a"
# local gruvbox_dark_colors="--color=bg+:#282828,bg:#282828,spinner:#fabd2f,hl:#fb4934 --color=fg:#ebdbb2,header:#fb4934,info:#b8bb26,pointer:#fabd2f --color=marker:#83a598,fg+:#ebdbb2,prompt:#b8bb26,hl+:#fb4934 --color=selected-bg:#3c3836"
# local fzf_colors=$gruvbox_colors
# local fzf_colors=$catpuccino_colors

export FZF_DEFAULT_OPTS="--height 50% --margin 1,2 --layout=reverse --border rounded --multi '--bind=shift-tab:up,tab:down,ctrl-space:toggle'" # Starts fzf in lower half of the screen taking 40% height

# if [[ $TMUX ]]; then
#   export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --tmux bottom,50%"
# fi
export FZF_DEFAULT_COMMAND="$find_all_cmd"
# export FZF_DEFAULT_COMMAND="fd --type file --follow . --exclude '*.pyc' --exclude '*.pyi' --exclude '.vscode'"
export FZF_CTRL_R_OPTS=""

export FZF_CTRL_T_COMMAND="$find_files_cmd"
export FZF_CTRL_T_OPTS="--preview-label='File preview' --preview 'bat --style=full --color always {}' $prev_win_opts"

# export FZF_ALT_C_COMMAND="fd --type directory --follow --exclude '.git' ."
export FZF_ALT_C_COMMAND="$find_dirs_cmd"
export FZF_ALT_C_OPTS="--preview-label='Files' --preview 'tree -C {}' $prev_win_opts"

export FZF_COMPLETION_TRIGGER="."
_fzf_compgen_path() {
  fd --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --follow --exclude ".git" . "$1"
}

fzf_all() {
  local find_all_cmd="fd --follow . $xcludes "
  local find_files_cmd="$find_all_cmd --type file "
  local find_dirs_cmd="$find_all_cmd --type directory "

  eval "$find_files_cmd" | fzf --prompt 'Files > ' --header '?: Switch between Files/Directories' --bind "?:transform:[[ ! \$FZF_PROMPT =~ Files ]] &&
    echo 'change-prompt(Files > )+reload($find_files_cmd)' ||
    echo 'change-prompt(Directories > )+reload($find_dirs_cmd)'" --preview '[[ $FZF_PROMPT =~ Files ]] && bat --color=always {} || eza -T -L=2 --color=always {}'
}
zle -N fzf_all
bindkey '^T' fzf_all



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
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind 'enter:become($EDITOR {1} +{2})'
}

add_to_zsh_history() {

  print -s $@
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
    fi
  done

  if [[ $# -gt 0 ]]; then
    local args=$@
    if $all_files; then
      ${EDITOR} $@
      return 0
    elif $all_dirs; then
      selected_files="$(eval $find_files_cmd $args | fzf --select-1 --exit-0 +m)"
    else
      echo "Arguments must of same type i.e. either all files or directories"
      return 1
    fi
  else
    # selected_files="$(eval $find_files_cmd $PWD | fzf --select-1 --exit-0 +m)"
    selected_files="$(eval $find_files_cmd | fzf --select-1 --exit-0 +m)"
  fi

  [[ ! -z $selected_files ]] && echo $selected_files && add_to_zsh_history "${EDITOR} ${selected_files}" && ${EDITOR} "${selected_files}" || return 1
}

gbf() {
  local branch=$(git branch | fzf --tmux left,30%,30% --bind "enter:accept-or-print-query" | tr -d ' ')
  git checkout $branch 2>/dev/null || git checkout -b $branch
}

gbfa() {
  git checkout $(git branch --all | fzf)
}


# fuzzy search through man pages with tldr preview
# fman() {
#   local paths="/usr/share/man /opt/homebrew/share/man $HOME/.local/share/devbox/global/default/.devbox/nix/profile/default/share/man"
#   fd_cmd="fd -t f . --follow $paths"
#   eval $fd_cmd | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}' |sort -u| fzf --layout reverse --prompt '∷ ' --pointer ▶ --marker ⇒ --height 70% --border=double --preview 'tldr --color=always {} 2>/dev/null' | xargs man
# }

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    # ssh)          fzf --preview 'dig {}'                   "$@" ;;
    man)            fzf --preview 'tldr --color=always {} 2>/dev/null' "$@" ;;
    cat|ls|eza)            fzf --preview '[[ ! -d {} ]] && bat --color=always {}|| tree -C {}' "$@" ;;
    *)            fzf  "$@" ;;
  esac
}

# custom hostname completion
__fzf_list_hosts() {
  local hosts=($(awk '/^Host / {print $2}' ~/.ssh/config.custom))
  hosts+=($(awk '!/rdev/ && !/k8s/ && /^[[:alpha:]]/ {print $1}' ~/.ssh/known_hosts))
  echo $hosts | tr ' ' '\n' | sort -u
}

 __fzf_list_man_pages() {
local paths="/usr/share/man /opt/homebrew/share/man $HOME/.local/share/devbox/global/default/.devbox/nix/profile/default/share/man"
fd_cmd="fd -t f . --follow $paths"
eval $fd_cmd | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}' |sort -u
}

_fzf_complete_man() {
_fzf_complete +m -- "$@" < <(__fzf_list_man_pages)
}
# source $HOME/fzf-themes/tokyonight_moon.sh
