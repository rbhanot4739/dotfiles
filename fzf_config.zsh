# vim:set ft=sh :

# =================================== Fzf config ===================================

local find_all_cmd="fd --ignore-file ~/.global_gitignore --follow ."
local find_files_cmd="$find_all_cmd --type file "
local find_dirs_cmd="$find_all_cmd --type directory "

local default_header_opts="--header-first --header-border=bottom --header 'Press ? to toggle preview'"
local default_binds='--bind "shift-tab:up,tab:down,ctrl-space:toggle,ctrl-a:toggle-all,ctrl-v:become(nvim {}),?:toggle-preview"'

local file_prev_opts="'bat --style=snip --color always {}' --preview-label='File Contents'  --preview-window right:50%"
local file_binds='--bind "alt-i:reload([ ! -f /tmp/fzf_hidden ] && (fd -tf -u --hidden && touch /tmp/fzf_hidden) || (fd -tf && rm -f /tmp/fzf_hidden))"'
local file_opts="--border-label='Fuzzy Files' --preview $file_prev_opts $file_binds"

local dir_prev_opts="'eza $eza_params {}' --preview-label=' Directory Contents '  --preview-window :down:20%:wrap"
local dir_binds='--bind "alt-i:reload([ ! -f /tmp/fzf_hidden ] && (fd -td -u --hidden && touch /tmp/fzf_hidden) || (fd -td && rm -f /tmp/fzf_hidden))"'
local dir_opts="--border-label='Fuzzy Directories' --preview $dir_prev_opts $dir_binds"

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
  ls | eza) eval "fzf --preview \"[[ ! -d {} ]] && $file_prev_opts \" \"\$@\"" ;;
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


local fzf_theme=$(cat /tmp/theme 2>/dev/null || echo "$THEME")
source $HOME/fzf-themes/${fzf_theme}.sh
