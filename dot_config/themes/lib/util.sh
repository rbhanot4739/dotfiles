# Small helpers shared by bin/ scripts. Source this file; do not execute it.
# Portable to bash 3.2 (macOS has no `timeout`, no GNU cp/readlink options).
#
#   run_limited <seconds> <cmd...>   run a command, kill it after <seconds>
#   atomic_copy <src> <dst>          copy via temp file + rename (readers never see half a file)

run_limited() {
  local secs="$1" pid watchdog rc
  shift
  "$@" &
  pid=$!
  ( sleep "$secs"; kill "$pid" 2>/dev/null ) >/dev/null 2>&1 &
  watchdog=$!
  wait "$pid" 2>/dev/null
  rc=$?
  kill "$watchdog" 2>/dev/null
  wait "$watchdog" 2>/dev/null
  return "$rc"
}

atomic_copy() {
  local src="$1" dst="$2" tmp
  mkdir -p "$(dirname "$dst")" || return 1
  tmp=$(mktemp "$dst.XXXXXX") || return 1
  if cp "$src" "$tmp" && chmod 644 "$tmp" && mv -f "$tmp" "$dst"; then
    return 0
  fi
  rm -f "$tmp"
  return 1
}
