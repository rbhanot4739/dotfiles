# vim:set ft=sh :
# Shared fzf/fzf-tab defaults and candidate helper functions.

# Idempotent guard.
[[ -n ${_FZF_COMMON_LOADED-} ]] && return
typeset -g _FZF_COMMON_LOADED=1

export FZF_HIDDEN_MARKER="${TMPDIR:-/tmp}/fzf_hidden_$$"

# Shared fd helper (also used by custom_config.zsh).
[[ -f "$HOME/.config/fzf/fd-args.zsh" ]] && source "$HOME/.config/fzf/fd-args.zsh"

# Shared fd args for all fzf candidate generation paths.
typeset -ga FZF_FD_ARGS=()
# Use shared builder when available so fd flags stay in one source of truth.
if (( $+functions[_fd_shared_args] )); then
  # Rebuild exact argv safely; preserves spaces/special chars in paths/flags.
  FZF_FD_ARGS=("${(@0)$(_fd_shared_args --follow)}")
else
  # Fallback if helper wasn't sourced; keeps fd usable in partial loads.
  FZF_FD_ARGS=(--ignore-file "${FD_SHARED_IGNORE_FILE:-$HOME/.ignore}" --follow)
fi
typeset -g FZF_FD_ARGS_STR="${(j: :)${(@q)FZF_FD_ARGS}}"
typeset -g FZF_FD_FIND_ALL_CMD="fd ${FZF_FD_ARGS_STR} ."
typeset -g FZF_FD_FIND_FILES_CMD="fd ${FZF_FD_ARGS_STR} --type file ."
typeset -g FZF_FD_FIND_DIRS_CMD="fd ${FZF_FD_ARGS_STR} --type directory ."

_fzf_fd() {
  command fd "${FZF_FD_ARGS[@]}" "$@"
}

# Context-specific headers (only advertise relevant keys).
# `: "${var:=default}"` keeps defaults overridable by environment.
: "${FZF_UNIFIED_HEADER_FILE:=Alt-i ignored  ·  Alt-s/d mark  ·  Alt-g all  ·  Alt-p preview  ·  ^v edit}"
: "${FZF_UNIFIED_HEADER_DIR:=Alt-i ignored  ·  Alt-s/d mark  ·  Alt-g all  ·  Alt-p preview}"
: "${FZF_UNIFIED_HEADER_ENV:=Alt-s/d mark  ·  Alt-g all  ·  Alt-p preview}"
: "${FZF_UNIFIED_HEADER_MAN:=Alt-p preview}"
: "${FZF_UNIFIED_PROMPT:=❯ }"
: "${FZF_UNIFIED_POINTER:=󰁕}"
: "${FZF_UNIFIED_LABEL_COLOR:=8}"
: "${FZF_UNIFIED_HEADER_COLOR:=8}"
: "${FZF_UNIFIED_PREVIEW_WINDOW:=right,55%,border-rounded,wrap}"
: "${FZF_UNIFIED_DIR_PREVIEW_WINDOW:=down,20%,border-top,wrap}"
export FZF_UNIFIED_PREVIEW_WINDOW

# Shared ghost text strings.
: "${FZF_GHOST_FILES:=Find files…}"
: "${FZF_GHOST_VIM:=Open file in vim…}"
: "${FZF_GHOST_DIRS:=Jump to directory…}"
: "${FZF_GHOST_MIXED:=Search files & dirs…}"
: "${FZF_GHOST_MAN:=Search man pages…}"
: "${FZF_GHOST_HISTORY:=Search history…}"
: "${FZF_GHOST_ENV:=Filter env vars…}"
: "${FZF_GHOST_HOSTS:=Search hosts…}"

# Hidden-file toggle commands (Alt-i).
: "${FZF_UNIFIED_HIDDEN_TOGGLE_ALL_CMD:=[ ! -f $FZF_HIDDEN_MARKER ] && (fd ${FZF_FD_ARGS_STR} -u --hidden . && touch $FZF_HIDDEN_MARKER) || (fd ${FZF_FD_ARGS_STR} . && rm -f $FZF_HIDDEN_MARKER)}"
: "${FZF_UNIFIED_HIDDEN_TOGGLE_FILE_CMD:=[ ! -f $FZF_HIDDEN_MARKER ] && (fd ${FZF_FD_ARGS_STR} -tf -u --hidden . && touch $FZF_HIDDEN_MARKER) || (fd ${FZF_FD_ARGS_STR} -tf . && rm -f $FZF_HIDDEN_MARKER)}"
: "${FZF_UNIFIED_HIDDEN_TOGGLE_DIR_CMD:=[ ! -f $FZF_HIDDEN_MARKER ] && (fd ${FZF_FD_ARGS_STR} -td -u --hidden . && touch $FZF_HIDDEN_MARKER) || (fd ${FZF_FD_ARGS_STR} -td . && rm -f $FZF_HIDDEN_MARKER)}"

# Preview templates. Single source per kind (file vs dir); sentinel @PATH@ is
# substituted to produce three variants:
#   {}        — ctrl-t / alt-c / trigger pickers (no --delimiter set)
#   {-1}      — fzf-tab Alt-i change-preview. fzf-tab sets --delimiter='\x00',
#               so old fzf-tab candidates carry a NUL between group and display.
#               `{}` would inject that NUL into the command string and Go's
#               exec rejects NUL args (`fork/exec /bin/zsh: invalid argument`).
#               `{-1}` returns the last NUL-delimited column — clean for both
#               pre-reload (display) and post-reload (whole path) candidates.
#   $realpath — fzf-tab initial preview (resolved by compcap lookup).
# Sentinel cannot start with `#` or `%` — zsh's ${//#…} and ${//%…} anchor to
# start/end of the string and would mis-match.
_FZF_DIR_PREVIEW_TPL='eza --git --group --group-directories-first --time-style=long-iso --color=always --icons @PATH@'
_FZF_FILE_PREVIEW_TPL='[[ -d @PATH@ ]] && tree -C @PATH@ || bat --style=snip --color=always @PATH@'
FZF_UNIFIED_COMPLETION_DIR_PREVIEW=${_FZF_DIR_PREVIEW_TPL//@PATH@/'{}'}
FZF_UNIFIED_COMPLETION_FILE_PREVIEW=${_FZF_FILE_PREVIEW_TPL//@PATH@/'{}'}
FZF_TAB_RELOAD_DIR_PREVIEW=${_FZF_DIR_PREVIEW_TPL//@PATH@/'{-1}'}
FZF_TAB_RELOAD_FILE_PREVIEW=${_FZF_FILE_PREVIEW_TPL//@PATH@/'{-1}'}
FZF_UNIFIED_FZF_TAB_DIR_PREVIEW=${_FZF_DIR_PREVIEW_TPL//@PATH@/'$realpath'}
FZF_UNIFIED_FZF_TAB_FILE_PREVIEW=${_FZF_FILE_PREVIEW_TPL//@PATH@/'$realpath'}

# Candidate-source helpers shared by fzf-trigger and fzf-tab.

__fzf_list_man_pages() {
  # Filter to identifier-like names to avoid bad completion tokens.
  local paths="/usr/share/man /opt/homebrew/share/man $HOME/.local/share/devbox/global/default/.devbox/nix/profile/default/share/man"
  command fd -t f . --follow ${=paths} 2>/dev/null \
    | command awk -F '/' '{print $NF}' \
    | command awk -F '.' '{print $1}' \
    | command grep -E '^[A-Za-z0-9_][A-Za-z0-9_.+-]*$' \
    | command sort -u
}

# Exported parameter names only.
__fzf_list_env_vars() {
  typeset -xp \
    | command sed 's/=.*//' \
    | command sed 's/.* //' \
    | command grep -E '^[A-Za-z_][A-Za-z0-9_]*$' \
    | command sort -u
}

__fzf_list_hosts() {
  # ~/.ssh/config.ranges and ~/.ssh/.range_hosts_cache come from refresh-ssh-hosts.
  local hosts=()
  [[ -f ~/.ssh/config.custom ]] && hosts+=($(command awk '/^Host / && $2 !~ /^\*/ {print $2}' ~/.ssh/config.custom))
  [[ -f ~/.ssh/config.ranges ]] && hosts+=($(command awk '/^Host / {print $2}' ~/.ssh/config.ranges))
  [[ -f ~/.ssh/config.rdev ]] && hosts+=($(command awk '/^Host / && $NF !~ /^\*/ {print $NF}' ~/.ssh/config.rdev))
  [[ -f ~/.ssh/.range_hosts_cache ]] && hosts+=(${(f)"$(< ~/.ssh/.range_hosts_cache)"})
  (( ${#hosts[@]} )) || return 0
  printf '%s\n' "${hosts[@]}" | command sort -u
}

# Shared fzf chrome: --header-first plus a start: bind that wipes the hidden-file
# toggle marker. Height is set per consumer: FZF_DEFAULT_OPTS uses `--height ~50%`
# (content-fitted) for ctrl-t/alt-c/gbf/gwt; fzf-tab's flags pin `--height=50%`
# fixed because fzf cannot re-size on reload (Alt-i toggle would otherwise leave
# a tiny popup).
typeset -ga _FZF_COMMON_CHROME=(
  --header-first
  --bind "start:execute-silent(rm -f $FZF_HIDDEN_MARKER)"
)

# Git log format shared by `gl`/`gla` (custom_config.zsh) and the git pickers below.
typeset -g _GIT_LOG_PRETTY_BASE='%C(auto)%h %s %C(green)(%ar) %C(bold blue)[%al]'
# Same fields as _BASE but delimited with US (0x1f) for awk parsing, with %D appended.
typeset -g _GIT_LOG_PRETTY_TAGGED=$'\x1f%C(auto)%h\x1f%s %C(green)(%ar) %C(bold blue)[%al]\x1f%D'

# POSIX-ERE used by sed (fzf previews) and awk (gl) to canonicalize tags:
# captures a semver-like suffix so dcl/v3.0.61, dcl_3.0.61, ucm-pie-core-dcl_0.0.46,
# and v3.0.61 all display as v3.0.61. Tags without a semver suffix pass through.
typeset -g _GIT_TAG_CANON_ERE='[0-9]+\.[0-9]+\.[0-9]+([._+-][A-Za-z0-9._-]+)?$'
