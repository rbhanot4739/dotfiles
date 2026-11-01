#!/usr/bin/env bash
# Run by tmux-layout.conf (tmux start / config reload): source the generated tmux colours
# of the active theme. If nothing has been generated yet (fresh host), generate once.
# Never fails: a missing theme only means the status bar keeps tmux's default colours.
set -u
ROOT="${THEMES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
. "$ROOT/lib/state.sh"

state_resolve
f=$(gen_find tmux conf) || {
  "$ROOT/bin/theme-generate" --no-apply --quiet >/dev/null 2>&1 || true
  f=$(gen_find tmux conf) || exit 0
}
tmux source-file "$f"
