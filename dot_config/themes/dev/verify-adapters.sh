#!/usr/bin/env bash
# Dev-only check for adapters/{tmux,fzf,delta,lazygit}. Not deployed.
#
# Usage: bash dev/verify-adapters.sh [--compare-old]
#   (default, ~5s)  checks 2-5 below
#   --compare-old   also runs check 1 (slow: ~1-2 min, the old adapters call python yq
#                   ~50 times per theme)
#
#   1. (--compare-old) Output is byte-identical to the OLD adapters (dot_config/themes-old/adapters) for
#      tmux, fzf and delta, and semantically identical for lazygit, for every theme
#      and mode. The old adapters need mikefarah-style yq, so a small shim around
#      the python yq stands in for it (needs python yq on PATH; else this part is
#      skipped).
#   2. No output contains a literal "null" / empty value.
#   3. fzf --opts matches the --color lines of the sourceable array format.
#   4. Failure paths: bad theme, bad mode, missing key -> non-zero, nothing on stdout.
#   5. Generated tmux/fzf/delta/lazygit output is accepted by the real tools.
set -u

# Don't let the caller's interactive environment change behaviour (or block):
# an fzf --tmux popup, a nested-tmux refusal, custom default options...
unset TMUX FZF_DEFAULT_OPTS FZF_DEFAULT_OPTS_FILE FZF_DEFAULT_COMMAND

COMPARE_OLD=0
[ "${1:-}" = "--compare-old" ] && COMPARE_OLD=1

# run_limited <seconds> <cmd...>   kill the command if it takes too long (macOS has no `timeout`)
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
step() { printf '== %s\n' "$*"; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OLD="$(cd "$ROOT/../themes-old" 2>/dev/null && pwd)"
. "$ROOT/lib/registry.sh"

A="$ROOT/adapters"
pass=0 fail=0
ok()  { pass=$((pass + 1)); }
bad() { fail=$((fail + 1)); echo "FAIL: $*" >&2; }

themes=$(registry_list)
modes_for() { theme_meta "$1" >/dev/null && { [ "$T_mode" = adaptive ] && echo "dark light" || echo "$T_mode"; }; }

# --- 1. compare with the old adapters ----------------------------------------
REAL_YQ=$(command -v yq || true)
step "1. comparison with old adapters"
if [ "$COMPARE_OLD" != 1 ]; then
  echo "   skipped (pass --compare-old to run it; slow)"
elif [ -n "$REAL_YQ" ] && yq --help 2>&1 | grep -qi 'jq wrapper' && [ -d "$OLD/adapters" ]; then
  work=$(mktemp -d)
  mkdir -p "$work/bin" "$work/home/.config/themes"
  ln -s "$THEMES_REGISTRY" "$work/home/.config/themes/registry"
  cat > "$work/bin/yq" <<SHIM
#!/usr/bin/env bash
# mikefarah-style call -> python yq: scalars raw (-r); the lazygit restructure as YAML (-y)
case "\$1" in *'{'*) exec "$REAL_YQ" -y "\$@" ;; *) exec "$REAL_YQ" -r "\$@" ;; esac
SHIM
  chmod +x "$work/bin/yq"
  old() { HOME="$work/home" PATH="$work/bin:$PATH" bash "$OLD/adapters/executable_$1" "$2" "$3"; }

  n=0
  for t in $themes; do
    printf '   %s\n' "$t"
    for m in $(modes_for "$t"); do
      for tool in tmux fzf delta; do
        # known, intended change: fzf bg/gutter of tokyonight night/storm/moon now equal the terminal background
        case "$tool:$t" in fzf:tokyonight-night|fzf:tokyonight-storm|fzf:tokyonight-moon) continue ;; esac
        if [ "$(old "$tool" "$t" "$m" 2>&1)" = "$(bash "$A/executable_$tool" "$t" "$m" 2>&1)" ]; then ok; n=$((n + 1)); else
          bad "$tool $t/$m differs from old adapter"
          diff <(old "$tool" "$t" "$m" 2>&1) <(bash "$A/executable_$tool" "$t" "$m" 2>&1) | head -4 >&2
        fi
      done
      # lazygit: compare the gui.theme tree (old one also set nerdFontsVersion, by design dropped)
      o=$(old lazygit "$t" "$m" 2>&1 | "$REAL_YQ" -c '.gui.theme' 2>&1)
      w=$(bash "$A/executable_lazygit" "$t" "$m" 2>&1 | "$REAL_YQ" -c '.gui.theme' 2>&1)
      if [ "$o" = "$w" ] && [ "$o" != "null" ] && [ -n "$o" ]; then ok; n=$((n + 1)); else bad "lazygit $t/$m differs: old=$o new=$w"; fi
    done
  done
  echo "   compared $n adapter outputs with the old adapters"
  rm -rf "$work"
else
  echo "   skipped: python yq or old adapters not available"
fi

# --- 2/3. sanity over every theme ----------------------------------------------
step "2/3. every theme x mode x adapter: output sane, fzf --opts matches array"
for t in $themes; do
  for m in $(modes_for "$t"); do
    for tool in tmux fzf delta lazygit; do
      out=$(bash "$A/executable_$tool" "$t" "$m" 2>&1) || { bad "$tool $t/$m exited non-zero: $out"; continue; }
      if printf '%s\n' "$out" | grep -qE '(^|[ "=:\[])null($|[ ",\]])'; then bad "$tool $t/$m contains a null value"; continue; fi
      if printf '%s\n' "$out" | grep -qE '=[ ]*$|""'; then bad "$tool $t/$m contains an empty value"; continue; fi
      ok
    done
    a=$(bash "$A/executable_fzf" "$t" "$m" | grep -o -- '--color=[^ ]*')
    b=$(bash "$A/executable_fzf" "$t" "$m" --opts)
    [ "$a" = "$b" ] && ok || bad "fzf --opts differs from array format for $t/$m"
    # the picker background must be the terminal background (tmux and nvim use it too)
    fb=$(printf '%s\n' "$b" | sed -n 's/^--color=bg://p' | tr 'A-F' 'a-f')
    tb=$(registry_dump_section "$t" "$m" colors | awk -F'\t' '$1=="background" {print $2}' | tr 'A-F' 'a-f')
    [ "$fb" = "$tb" ] && ok || bad "fzf bg ($fb) != terminal background ($tb) for $t/$m"
  done
done

# --- 4. failure paths -----------------------------------------------------------
step "4. failure paths"
for tool in tmux fzf delta lazygit; do
  out=$(bash "$A/executable_$tool" no-such-theme dark 2>/dev/null) && bad "$tool: unknown theme should fail" || { [ -z "$out" ] && ok || bad "$tool: stdout not empty on failure"; }
  out=$(bash "$A/executable_$tool" tokyonight-night purple 2>/dev/null) && bad "$tool: bad mode should fail" || ok
  out=$(bash "$A/executable_$tool" everforest sepia 2>/dev/null) && bad "$tool: bad mode on adaptive should fail" || ok
  out=$(bash "$A/executable_$tool" 2>/dev/null) && bad "$tool: missing args should fail" || ok
done
tmp=$(mktemp -d)
grep -v 'prefix_indicator' "$ROOT/registry/tokyonight-night.yaml" > "$tmp/tokyonight-night.yaml"
out=$(THEMES_REGISTRY="$tmp" bash "$A/executable_tmux" tokyonight-night dark 2>"$tmp/err") && bad "missing key should fail" || {
  [ -z "$out" ] && grep -q 'prefix_indicator' "$tmp/err" && ok || bad "missing key: expected empty stdout and an error naming prefix_indicator"; }
rm -rf "$tmp"

# --- 5. accepted by the real tools ----------------------------------------------
step "5. accepted by tmux / git / fzf (each call limited to 10s)"
if command -v tmux >/dev/null 2>&1; then
  sock=$(mktemp -d); f="$sock/theme.conf"
  bash "$A/executable_tmux" tokyonight-night dark > "$f"
  export TMUX_TMPDIR="$sock"
  if run_limited 10 tmux -L verify -f /dev/null new-session -d -s v </dev/null >/dev/null 2>&1 \
     && run_limited 10 tmux -L verify source-file "$f" </dev/null >/dev/null 2>&1 \
     && [ "$(run_limited 10 tmux -L verify show -gv @DEFAULT_BG </dev/null 2>/dev/null)" = "#1a1b26" ]; then ok; else bad "tmux did not accept/apply the generated config"; fi
  run_limited 10 tmux -L verify kill-server </dev/null >/dev/null 2>&1
  unset TMUX_TMPDIR; rm -rf "$sock"
fi
if command -v git >/dev/null 2>&1; then
  g=$(mktemp -d)
  { bash "$A/executable_delta" tokyonight-night dark; bash "$A/executable_delta" everforest light; } > "$g/c"
  # git strips the quotes: `syntax "#20303b"` is read as `syntax #20303b` (what delta expects)
  [ "$(git config -f "$g/c" --get delta.tokyonight-night.plus-style)" = 'syntax #20303b' ] && ok || bad "git cannot read delta section / wrong value"
  [ "$(git config -f "$g/c" --get delta.everforest-light.minus-emph-style)" = '#ffffff #e67e80' ] && ok || bad "git: everforest minus-emph-style"
  [ "$(git config -f "$g/c" --list | wc -l | tr -d ' ')" = 22 ] && ok || bad "git did not read all 2x11 delta keys"
  rm -rf "$g"
fi
if command -v fzf >/dev/null 2>&1; then
  o=$(bash "$A/executable_fzf" tokyonight-night dark --opts | tr '\n' ' ')
  # shellcheck disable=SC2086
  if printf 'a\nb\n' | run_limited 10 fzf --filter a $o >/dev/null 2>&1; then ok; else bad "fzf rejected --opts colors"; fi
  f=$(mktemp)
  bash "$A/executable_fzf" everforest light --opts > "$f"
  if printf 'a\nb\n' | FZF_DEFAULT_OPTS_FILE="$f" run_limited 10 fzf --filter a >/dev/null 2>&1; then ok; else bad "fzf rejected FZF_DEFAULT_OPTS_FILE"; fi
  rm -f "$f"
fi

echo "passed: $pass  failed: $fail"
[ "$fail" -eq 0 ]
