#!/usr/bin/env bash
# Dev-only check for lib/registry.{sh,awk}. Not deployed (see .chezmoiignore).
#
#   1. Every theme/section/mode parses, and matches python-yq's reading (if `yq`
#      is the jq-wrapper flavour; otherwise this comparison is skipped).
#   2. theme_meta / theme_load / theme_need behave, including failure cases.
#   3. No bash-4-only constructs in the portable core (bash 3.2 on macOS).
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib/registry.sh
. "$ROOT/lib/registry.sh"

pass=0 fail=0
ok()   { pass=$((pass + 1)); }
bad()  { fail=$((fail + 1)); echo "FAIL: $*" >&2; }

SECTIONS="colors terminal tmux fzf delta lazygit"

# --- 1. compare against python yq ---------------------------------------------
have_pyyq=0
if yq --version 2>&1 | grep -q '^yq [0-9]' && yq --help 2>&1 | grep -qi 'jq wrapper'; then
  have_pyyq=1
fi

ref_section() { # theme mode section  (python yq, same output shape as awk)
  yq -r --arg m "$2" --arg s "$3" '
    (if .mode == "adaptive" then (.[$m] // error("no variant")) else . end)
    | (.[$s] // error("no section"))
    | to_entries[]
    | "\(.key)\t\(.value | if type == "string" then . else tojson end)"
  ' "$THEMES_REGISTRY/$1.yaml" 2>/dev/null
}

count=0
for theme in $(registry_list); do
  theme_meta "$theme" || { bad "theme_meta $theme"; continue; }
  if [ "$T_mode" = adaptive ]; then modes="dark light"; else modes="$T_mode"; fi
  for mode in $modes; do
    for sect in $SECTIONS; do
      got=$(registry_dump_section "$theme" "$mode" "$sect" 2>/dev/null); got_rc=$?
      if [ "$have_pyyq" = 1 ]; then
        want=$(ref_section "$theme" "$mode" "$sect"); want_rc=$?
        if [ "$got_rc" -ne 0 ] && [ "$want_rc" -ne 0 ]; then ok; continue; fi
        if [ "$got_rc" -ne 0 ] || [ "$want_rc" -ne 0 ]; then
          bad "$theme/$mode/$sect: exit status differs (awk=$got_rc yq=$want_rc)"; continue
        fi
        if [ "$got" = "$want" ]; then ok; count=$((count + 1)); else
          bad "$theme/$mode/$sect: output differs"
          diff <(printf '%s\n' "$want") <(printf '%s\n' "$got") | head -5 >&2
        fi
      else
        [ "$got_rc" -eq 0 ] && { ok; count=$((count + 1)); } || bad "$theme/$mode/$sect: parse failed"
      fi
    done
  done
done
if [ "$have_pyyq" = 1 ]; then
  echo "compared $count theme/mode/section combinations with python yq"
else
  echo "python yq not found: parsed $count combinations without comparing"
fi

# --- 2. API behaviour ----------------------------------------------------------
theme_meta tokyonight-night && [ "$T_mode" = dark ] && [ -n "$T_description" ] && ok || bad "theme_meta tokyonight-night"
theme_meta everforest       && [ "$T_mode" = adaptive ] && ok || bad "theme_meta everforest"

theme_load tokyonight-night dark tmux && [ "$V_default_bg" = "#1a1b26" ] && ok || bad "theme_load single-mode value"
theme_load everforest dark delta  && [ "$V_section_name" = "everforest-dark" ]  && ok || bad "adaptive dark"
theme_load everforest light delta && [ "$V_section_name" = "everforest-light" ] && ok || bad "adaptive light"
theme_load tokyonight-night dark lazygit && [ "$V_active_border_color" = '["#ff9e64","bold"]' ] && ok || bad "list value"
theme_load tokyonight-night dark delta && [ "$V_minus_style" = 'syntax "#37222c"' ] && ok || bad "single-quoted value with inner quotes"

theme_load tokyonight-night dark tmux
THEME=tokyonight-night
theme_need default_bg active_pane_border 2>/dev/null && ok || bad "theme_need present keys"
theme_need default_bg no_such_key 2>/dev/null && bad "theme_need should fail on missing key" || ok
theme_load tokyonight-night dark nope 2>/dev/null && bad "missing section should fail" || ok
theme_load no-such-theme dark tmux 2>/dev/null && bad "missing theme should fail" || ok
theme_load everforest sepia delta 2>/dev/null && bad "unknown adaptive variant should fail" || ok

# stale variables must not leak between loads
theme_load tokyonight-night dark tmux; theme_load tokyonight-night dark fzf
[ -z "${V_default_bg:-}" ] && ok || bad "V_ variables leaked across theme_load calls"

# malformed input is rejected loudly, not skipped
tmp=$(mktemp -d)
printf 'name: x\nmode: dark\ntmux:\n  - not a mapping\n' > "$tmp/x.yaml"
THEMES_REGISTRY="$tmp" registry_dump_section x dark tmux >/dev/null 2>&1 && bad "list item line should be rejected" || ok
printf 'name: x\nmode: dark\ntmux:\n  a: "unterminated\n' > "$tmp/x.yaml"
THEMES_REGISTRY="$tmp" registry_dump_section x dark tmux >/dev/null 2>&1 && bad "unterminated quote should be rejected" || ok
printf 'name: y\nmode: dark\n' > "$tmp/x.yaml"
THEMES_REGISTRY="$tmp" theme_meta x >/dev/null 2>&1 && bad "name/file mismatch should be rejected" || ok
rm -rf "$tmp"

# --- 3. bash 3.2 portability scan ---------------------------------------------
# Hits are bash >= 4 features (or GNU-only tools) that would break on macOS.
scan=$(grep -rnE 'declare -A|typeset -A|local -A|mapfile|readarray|\$\{[A-Za-z_]+(,,|\^\^|@[QEPAa])\}|&>>|\|&|;;&|;&|coproc|local -n|declare -n|\[\[ -v |readlink -f|sed -i|\btimeout [0-9]' \
  "$ROOT/lib" "$ROOT/adapters" "$ROOT/bin" 2>/dev/null | grep -v 'lib/tmux/')
if [ -z "$scan" ]; then ok; else bad "bash-4/GNU-only constructs found:"; echo "$scan" >&2; fi

echo "passed: $pass  failed: $fail"
[ "$fail" -eq 0 ]
