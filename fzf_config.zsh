# vim:set ft=sh :

# =================================== Fzf config ===================================

export FZF_HIDDEN_MARKER="${TMPDIR:-/tmp}/fzf_hidden_$$"
find_all_cmd="fd --ignore-file ~/.ignore --follow ."
find_files_cmd="$find_all_cmd --type file "
find_dirs_cmd="$find_all_cmd --type directory "
export FZF_DEFAULT_COMMAND="$find_all_cmd"
: "${FZF_UNIFIED_HEADER:=Quick keys: Alt-i toggle ignored | Alt-s/Alt-d mark + move}"
: "${FZF_UNIFIED_PROMPT:=❯ }"
: "${FZF_UNIFIED_POINTER:=󰁕}"
: "${FZF_UNIFIED_LABEL_COLOR:=8}"
: "${FZF_UNIFIED_PREVIEW_WINDOW:=right,55%,border-rounded,wrap}"
: "${FZF_UNIFIED_DIR_PREVIEW_WINDOW:=down,20%,border-top,wrap}"
# Ghost text strings (single source of truth — referenced by opts arrays and call sites)
: "${FZF_GHOST_FILES:=Find files…}"
: "${FZF_GHOST_VIM:=Open file in vim…}"
: "${FZF_GHOST_DIRS:=Jump to directory…}"
: "${FZF_GHOST_MIXED:=Search files & dirs…}"
: "${FZF_GHOST_MAN:=Search man pages…}"
: "${FZF_GHOST_HISTORY:=Search history…}"
: "${FZF_GHOST_ENV:=Filter env vars…}"
: "${FZF_GHOST_HOSTS:=Search hosts…}"
: "${FZF_UNIFIED_HIDDEN_TOGGLE_ALL_CMD:=[ ! -f $FZF_HIDDEN_MARKER ] && (fd --ignore-file ~/.ignore -u --hidden . && touch $FZF_HIDDEN_MARKER) || (fd --ignore-file ~/.ignore . && rm -f $FZF_HIDDEN_MARKER)}"
: "${FZF_UNIFIED_HIDDEN_TOGGLE_FILE_CMD:=[ ! -f $FZF_HIDDEN_MARKER ] && (fd --ignore-file ~/.ignore -tf -u --hidden . && touch $FZF_HIDDEN_MARKER) || (fd --ignore-file ~/.ignore -tf . && rm -f $FZF_HIDDEN_MARKER)}"
: "${FZF_UNIFIED_HIDDEN_TOGGLE_DIR_CMD:=[ ! -f $FZF_HIDDEN_MARKER ] && (fd --ignore-file ~/.ignore -td -u --hidden . && touch $FZF_HIDDEN_MARKER) || (fd --ignore-file ~/.ignore -td . && rm -f $FZF_HIDDEN_MARKER)}"
_fzf_theme_opts_str=""
theme_opts=()
source "$HOME/.config/themes/lib/resolve-theme.sh"
_fzf_theme_file="$HOME/.config/themes/generated/fzf/${THEME}-${BG_MODE}.sh"
if [[ -f "$_fzf_theme_file" ]]; then
  source "$_fzf_theme_file"
elif [[ -f "$HOME/.config/themes/generated/fzf/${THEME}.sh" ]]; then
  source "$HOME/.config/themes/generated/fzf/${THEME}.sh"
fi
if (( ${#theme_opts[@]} )); then
  _fzf_theme_opts_str="${(j: :)theme_opts}"
fi
FZF_SHARED_KEYBINDS="\
--bind='tab:down,shift-tab:up' \
--bind='alt-s:select+down,alt-d:deselect+up' \
--bind='alt-g:toggle-all,alt-x:deselect-all' \
--bind='alt-p:toggle-preview' \
--bind='alt-w:change-preview-window(${FZF_UNIFIED_PREVIEW_WINDOW}|down,40%,border-top,wrap|hidden)' \
--bind='ctrl-v:execute(nvim {})+abort'"
export FZF_DEFAULT_OPTS="--ansi --cycle --style full --info=inline-right --height 50% --margin 1,2 --layout=reverse --border rounded --prompt '${FZF_UNIFIED_PROMPT}' --pointer '${FZF_UNIFIED_POINTER}' --color='label:${FZF_UNIFIED_LABEL_COLOR}' ${FZF_SHARED_KEYBINDS} ${_fzf_theme_opts_str}"
export FZF_COMPLETION_OPTS="${FZF_DEFAULT_OPTS}"
export FZF_UNIFIED_PREVIEW_WINDOW
FZF_UNIFIED_COMPLETION_DIR_PREVIEW='eza --git --group --group-directories-first --time-style=long-iso --color=always --icons {}'
FZF_UNIFIED_COMPLETION_FILE_PREVIEW='[[ -d {} ]] && tree -C {} || bat --style=snip --color=always {}'
export FZF_COMPLETION_PATH_OPTS="--multi --preview-window '${FZF_UNIFIED_PREVIEW_WINDOW}'"
export FZF_COMPLETION_DIR_OPTS="--multi --preview-window '${FZF_UNIFIED_DIR_PREVIEW_WINDOW}'"
completion_find_all_cmd="fd --ignore-file ~/.ignore --follow ."
completion_find_files_cmd="$completion_find_all_cmd --type file "
completion_find_dirs_cmd="$completion_find_all_cmd --type directory "

file_prev_opts_arr=(
 --preview '[[ -d {} ]] && tree -C {} || bat --style=snip --color=always {}'
 --preview-window "$FZF_UNIFIED_PREVIEW_WINDOW"
)
file_binds_arr=(
 --bind "start:execute-silent(rm -f $FZF_HIDDEN_MARKER)"
 --bind "alt-i:reload(${FZF_UNIFIED_HIDDEN_TOGGLE_FILE_CMD})"
)
file_opts_arr=(
 --border-label 'Fuzzy Find Files'
 --ghost "$FZF_GHOST_FILES"
 --header "$FZF_UNIFIED_HEADER"
 --header-first
 "${file_prev_opts_arr[@]}"
 "${file_binds_arr[@]}"
)
file_opts_str="${(j: :)${(@q)file_opts_arr}}"
export FZF_CTRL_T_COMMAND="$find_files_cmd"
export FZF_CTRL_T_OPTS="${FZF_DEFAULT_OPTS} ${file_opts_str}"

dir_prev_opts_arr=(
  --preview "eza $eza_params {}"
  --preview-window "$FZF_UNIFIED_DIR_PREVIEW_WINDOW"
)

dir_binds_arr=(
  --bind "start:execute-silent(rm -f $FZF_HIDDEN_MARKER)"
  --bind "alt-i:reload(${FZF_UNIFIED_HIDDEN_TOGGLE_DIR_CMD})"
)

dir_opts_arr=(
  --border-label "Fuzzy Find Dirs"
  --ghost "$FZF_GHOST_DIRS"
  --header "$FZF_UNIFIED_HEADER"
  --header-first
  "${dir_prev_opts_arr[@]}"
  "${dir_binds_arr[@]}"
)
mixed_opts_arr=(
  --border-label "Fuzzy Files/Dirs"
  --ghost "$FZF_GHOST_MIXED"
  --header "$FZF_UNIFIED_HEADER"
  --header-first
  --preview "[[ -d {} ]] && tree -C {} || bat --style=snip --color=always {}"
  --preview-window "$FZF_UNIFIED_PREVIEW_WINDOW"
  --bind "start:execute-silent(rm -f $FZF_HIDDEN_MARKER)"
  --bind "alt-i:reload(${FZF_UNIFIED_HIDDEN_TOGGLE_ALL_CMD})"
)

dir_opts_str="${(j: :)${(@q)dir_opts_arr}}"
export FZF_ALT_C_COMMAND="$find_dirs_cmd"
export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS $dir_opts_str"


export FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS --ghost '$FZF_GHOST_HISTORY' --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_COMPLETION_TRIGGER=","

_fzf_compgen_path() {
  [[ "$1" == "." ]] && eval "$completion_find_all_cmd --strip-cwd-prefix=always" || eval "$completion_find_all_cmd $1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  [[ "$1" == "." ]] && eval "$completion_find_dirs_cmd --strip-cwd-prefix=always" || eval "$completion_find_dirs_cmd $1"
}

__fzf_list_hosts() {
  # ~/.ssh/config.ranges and ~/.ssh/.range_hosts_cache are generated by ~/scripts/refresh-ssh-hosts
  local hosts=()
  [[ -f ~/.ssh/config.custom ]] && hosts+=($(command awk '/^Host / && $2 !~ /^\*/ {print $2}' ~/.ssh/config.custom))
  [[ -f ~/.ssh/config.ranges ]] && hosts+=($(command awk '/^Host / {print $2}' ~/.ssh/config.ranges))
  [[ -f ~/.ssh/config.rdev ]] && hosts+=($(command awk '/^Host / && $NF !~ /^\*/ {print $NF}' ~/.ssh/config.rdev))
  [[ -f ~/.ssh/.range_hosts_cache ]] && hosts+=(${(f)"$(< ~/.ssh/.range_hosts_cache)"})
  echo $hosts | command tr ' ' '\n' | sort -u
}

__fzf_list_man_pages() {
  local paths="/usr/share/man /opt/homebrew/share/man $HOME/.local/share/devbox/global/default/.devbox/nix/profile/default/share/man"
  fd_cmd="command fd -t f . --follow $paths"
  eval $fd_cmd | command awk -F '/' '{print $NF}' | command awk -F '.' '{print $1}' | command sort -u
}

_fzf_complete_man() {
  _fzf_complete +m -- "$@" < <(__fzf_list_man_pages)
}

fzf() {
  # Define base options locally.
  local -a default_opts
  default_opts=(
    --style full --info=inline-right --height 60% --margin 1,2 --layout=reverse
    --border rounded --multi
  )

  # local background_mode selected_theme theme_file
  # Do not remove below line, theme_opts is returned by fzf-theme files
  local -a theme_opts

  source "$HOME/.config/themes/lib/resolve-theme.sh"
  selected_theme=$THEME
  local _bg_mode=$BG_MODE
  local _gen_fzf="$HOME/.config/themes/generated/fzf"

  if [[ -f "${_gen_fzf}/${selected_theme}-${_bg_mode}.sh" ]]; then
    set -o noglob
    source "${_gen_fzf}/${selected_theme}-${_bg_mode}.sh"
    set +o noglob
  elif [[ -f "${_gen_fzf}/${selected_theme}.sh" ]]; then
    set -o noglob
    source "${_gen_fzf}/${selected_theme}.sh"
    set +o noglob
  fi

  # Execute the real fzf command with all options combined.
  command fzf "${default_opts[@]}" "${theme_opts[@]}" "$@"
}

# some git helpers
gbf() {
  git branch | grep -v "^\*" | fzf --preview "git log --graph --color=always --abbrev-commit --pretty=format:'%C(auto)%h%C(auto)%d %s %C(green)(%ar) %C(bold blue)[%al]'" | xargs git switch
}

gbfa() {
  git branch --all | grep -v "^\*" | fzf --preview "git log --graph --all --color=always --abbrev-commit --pretty=format:'%C(auto)%h%C(auto)%d %s %C(green)(%ar) %C(bold blue)[%al]'" | sed 's|^ *||; s|remotes/origin/||' | xargs git switch
}

gwt() {
    local selected selected_path
    selected=$(
        git worktree list --porcelain \
        | awk '
            /^worktree / { path=$2 }
            /^branch / {
              branch=$2; sub("^refs/heads/", "", branch);
              print path "\t" branch
            }
        ' \
        | fzf --delimiter=$'\t' --with-nth=2 --no-preview
    ) || return

    selected_path=${selected%%$'\t'*}
    cd "$selected_path" || return
}

_fzf_comprun() {
  local command=$1
  shift

case "$command" in
cd | z) command fzf "${dir_opts_arr[@]}" "$@" ;;
export | unset) command fzf --ghost "$FZF_GHOST_ENV" --preview "eval 'echo \$'{}" "$@" ;;
man) command fzf --ghost "$FZF_GHOST_MAN" --preview 'tldr --color=always {} 2>/dev/null' "$@" ;;
bat | cat) command fzf "${file_opts_arr[@]}" "$@" ;;
ls | eza) command fzf "${mixed_opts_arr[@]}" "$@" ;;
*) command fzf "$@" ;;
esac
}
