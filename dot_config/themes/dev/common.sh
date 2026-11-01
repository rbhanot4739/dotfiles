# Shared helpers for dev/verify-*.sh (dev-only, never deployed).

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"     # .../dot_config/themes
REPO="$(cd "$ROOT/../.." && pwd)"                            # chezmoi source root

pass=0 fail=0
ok()   { pass=$((pass + 1)); }
bad()  { fail=$((fail + 1)); echo "FAIL: $*" >&2; }
step() { printf '== %s\n' "$*"; }
summary() { echo "passed: $pass  failed: $fail"; [ "$fail" -eq 0 ]; }

# Start from a clean, non-interactive environment.
unset TMUX FZF_DEFAULT_OPTS FZF_DEFAULT_OPTS_FILE FZF_DEFAULT_COMMAND

# run_limited <seconds> <cmd...>   kill the command if it takes too long
run_limited() {
  local secs="$1" pid watchdog rc
  shift
  "$@" &
  pid=$!
  ( sleep "$secs"; kill "$pid" 2>/dev/null ) >/dev/null 2>&1 &
  watchdog=$!
  wait "$pid" 2>/dev/null; rc=$?
  kill "$watchdog" 2>/dev/null; wait "$watchdog" 2>/dev/null
  return "$rc"
}

# deploy_tmp [mac]: install themes into a scratch HOME exactly the way `chezmoi apply`
# does (real file-name transforms, exec bits, ignore rules), without touching the
# real home. Sets SANDBOX (scratch HOME) and THEMES ($SANDBOX/.config/themes).
# With "mac" the chezmoi data is overridden to is_mac=true, so the macOS-only files
# (Ghostty/WezTerm adapters and hooks) are deployed as they would be on a Mac.
deploy_tmp() {
  local data='{"is_mac":false}'
  [ "${1:-}" = mac ] && data='{"is_mac":true}'
  SANDBOX=$(mktemp -d)
  mkdir -p "$SANDBOX/.config"
  if command -v chezmoi >/dev/null 2>&1; then
    chezmoi --override-data "$data" apply --source "$REPO" --destination "$SANDBOX" \
      --persistent-state "$SANDBOX/.chezmoistate.boltdb" --force \
      "$SANDBOX/.config/themes" >/dev/null 2>&1 || { echo "chezmoi apply into scratch dir failed" >&2; return 1; }
    rm -f "$SANDBOX/.chezmoistate.boltdb"
  else
    [ "${1:-}" = mac ] && { echo "chezmoi is required to test the macOS overlay" >&2; return 1; }
    echo "note: chezmoi not found, emulating apply (strips executable_ prefix, skips dev/)" >&2
    mkdir -p "$SANDBOX/.config/themes"
    ( cd "$ROOT" && find . -type f -not -path './dev/*' ) | while read -r f; do
      d="$SANDBOX/.config/themes/$(dirname "$f")"; b=$(basename "$f")
      mkdir -p "$d"; cp "$ROOT/$f" "$d/${b#executable_}"
      case "$b" in executable_*) chmod +x "$d/${b#executable_}" ;; esac
    done
  fi
  THEMES="$SANDBOX/.config/themes"
}

# tree_sum <dir>: content checksum of every file (portable md5/shasum), stable order
tree_sum() {
  ( cd "$1" && find . -type f | LC_ALL=C sort | while read -r f; do
      if command -v md5sum >/dev/null 2>&1; then md5sum "$f"; else md5 -r "$f"; fi
    done )
}
