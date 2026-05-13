# vim:set ft=zsh :
# Shared fd argument builder used by shell wrappers and fzf configs.

# `${var-}` avoids "unbound variable" with `set -u`; return if already sourced.
[[ -n ${_FD_ARGS_HELPER_LOADED-} ]] && return
typeset -g _FD_ARGS_HELPER_LOADED=1

# `: "${var:=default}"` sets a default only when var is unset/empty.
: "${FD_SHARED_IGNORE_FILE:=$HOME/.ignore}"
: "${FD_SHARED_IGNORE_CONTAIN_MARKER:=CACHEDIR.TAG}"

_fd_args_for_ignore_file() {
  # `emulate -L zsh` runs with zsh semantics and local option scope.
  emulate -L zsh
  local ignore_file="$1"
  # `${2:-...}` means "use arg2 if present, else fallback default".
  local marker="${2:-CACHEDIR.TAG}"
  shift 2

  local -a args=(--ignore-file "$ignore_file")
  if [[ -n "$marker" ]] && [[ "$(command fd --help 2>/dev/null)" == *"--ignore-contain"* ]]; then
    args+=(--ignore-contain "$marker")
  fi
  args+=("$@")

  # Emit NUL-delimited items so callers can rebuild arrays safely.
  printf '%s\0' "${args[@]}"
}

_fd_shared_args() {
  # Keep helper behavior local and predictable in mixed-shell environments.
  emulate -L zsh
  _fd_args_for_ignore_file "$FD_SHARED_IGNORE_FILE" "$FD_SHARED_IGNORE_CONTAIN_MARKER" "$@"
}
