#!/usr/bin/env bash
# Dev-only check for the macOS-only overlay (Ghostty / WezTerm). Not deployed.
# Runs on Linux too: the Mac deployment is simulated with `chezmoi --override-data is_mac=true`
# into a scratch HOME, terminals are faked with plain files. Nothing real is touched.
#
# Usage: bash dev/verify-mac.sh [--compare-old]
#   --compare-old  also compare the ghostty/wezterm adapters with the old ones (slow, needs python yq)
#
#   A. Linux deployment (is_mac=false): no Mac file is deployed, core still works.
#   B. Mac deployment: files present + executable; generate hooks; apply hooks; OSC hook.
#   C. bash 3.2 portability scan of everything Mac-only.
set -u
. "$(dirname "$0")/common.sh"

COMPARE_OLD=0
[ "${1:-}" = "--compare-old" ] && COMPARE_OLD=1

command -v chezmoi >/dev/null 2>&1 || { echo "chezmoi is required for this check" >&2; exit 1; }

REAL_HOME="$HOME"
export THEMES_SKIP_NVIM=1
SANDBOXES=""
cleanup() { for d in $SANDBOXES; do rm -rf "$d"; done; }
trap cleanup EXIT

MAC_FILES="adapters/ghostty adapters/wezterm
hooks/generate.d/50-mac-ghostty hooks/generate.d/50-mac-wezterm
hooks/apply.d/50-mac-ghostty hooks/apply.d/50-mac-wezterm hooks/apply.d/60-mac-terminal-osc"

eq() { [ "$1" = "$2" ] && ok || bad "$3: got '$1', expected '$2'"; }

# ============================================================================
step "A. Linux deployment: nothing macOS-only is installed, core still works"
deploy_tmp || exit 1
SANDBOXES="$SANDBOXES $SANDBOX"
LT="$THEMES"; LS="$SANDBOX"
for f in $MAC_FILES; do
  [ -e "$LT/$f" ] && bad "Linux deployment contains $f" || ok
done
[ -e "$LS/.config/ghostty" ] && bad "Linux must not deploy ~/.config/ghostty" || ok
[ -e "$LS/.wezterm.lua" ] && bad "Linux must not deploy ~/.wezterm.lua" || ok
for f in bin/theme-switch bin/theme-generate adapters/tmux adapters/fzf adapters/delta adapters/lazygit lib/registry.sh; do
  [ -e "$LT/$f" ] && ok || bad "core file missing on Linux: $f"
done
out=$(HOME="$LS" THEMES_GENERATED="$LS/gen" "$LT/bin/theme-switch" --apply 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "core switch failed on Linux deployment rc=$rc: $out"
printf '%s' "$out" | grep -qi 'ghostty\|wezterm\|recoloured' && bad "Linux run mentions Mac pieces: $out" || ok
[ -e "$LS/gen/ghostty" ] && bad "Linux generate created ghostty output" || ok
[ -e "$LS/.config/wezterm" ] && bad "Linux generate created wezterm output" || ok
[ -e "$LS/.wezterm_themes.lua" ] && bad "Linux generate created ~/.wezterm_themes.lua" || ok

step "A2. chezmoi ignore rules"
ign_linux=$(chezmoi --override-data '{"is_mac":false}' ignored 2>/dev/null)
ign_mac=$(chezmoi --override-data '{"is_mac":true}' ignored 2>/dev/null)
for f in $MAC_FILES; do
  printf '%s\n' "$ign_linux" | grep -qx ".config/themes/$f" && ok || bad "Linux should ignore $f"
  printf '%s\n' "$ign_mac"   | grep -qx ".config/themes/$f" && bad "Mac must not ignore $f" || ok
done
printf '%s\n' "$ign_linux" | grep -qx '.config/ghostty' && ok || bad "Linux should ignore .config/ghostty"
printf '%s\n' "$ign_mac"   | grep -qx '.config/ghostty' && bad "Mac must not ignore .config/ghostty" || ok

# ============================================================================
step "B1. Mac deployment: files installed with exec bits"
deploy_tmp mac || exit 1
SANDBOXES="$SANDBOXES $SANDBOX"
export HOME="$SANDBOX"
export THEMES_GENERATED="$SANDBOX/gen"
MT="$THEMES"
for f in $MAC_FILES; do
  [ -x "$MT/$f" ] && ok || bad "Mac deployment: $f missing or not executable"
done
. "$MT/lib/registry.sh"
reg() { registry_dump_section "$1" "$2" "$3" | awk -F'\t' -v k="$4" '$1==k {print $2}'; }
keys=""
for t in $(registry_list); do
  theme_meta "$t"
  if [ "$T_mode" = adaptive ]; then keys="$keys $t-dark $t-light"; else keys="$keys $t"; fi
done
nkeys=$(echo $keys | wc -w | tr -d ' ')
echo "   $nkeys theme keys"

step "B2. theme-generate runs the Mac generate hooks"
out=$("$MT/bin/theme-generate" --no-apply 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "theme-generate rc=$rc: $out"
for k in $keys; do
  g="$THEMES_GENERATED/ghostty/$k.conf"
  [ -s "$g" ] || { bad "missing ghostty/$k.conf"; continue; }
  if grep -q '^theme = ' "$g"; then
    [ "$(wc -l < "$g" | tr -d ' ')" = 1 ] && ok || bad "$k: built-in ghostty theme file should be one line"
  else
    eq "$(grep -c '^palette = ' "$g")" 16 "$k palette lines"
    grep -q '^background = #' "$g" && grep -q '^foreground = #' "$g" && grep -q '^cursor-color = #' "$g" && ok || bad "$k: ghostty colours incomplete"
  fi
  grep -qi 'null' "$g" && bad "$k: 'null' in ghostty conf" || ok
  [ -s "$HOME/.config/wezterm/colors/$k.toml" ] && ok || bad "missing wezterm/colors/$k.toml"
done
eq "$(ls "$THEMES_GENERATED/ghostty" | wc -l | tr -d ' ')" "$nkeys" "number of ghostty confs"
eq "$(ls "$HOME/.config/wezterm/colors"/*.toml | wc -l | tr -d ' ')" "$nkeys" "number of wezterm schemes"
ls -A "$THEMES_GENERATED/ghostty" "$HOME/.config/wezterm/colors" | grep -q '^\.stage' && bad "staging dir left behind" || ok

step "B3. wezterm output is valid"
if python3 -c 'import tomllib' 2>/dev/null; then
  for k in $keys; do
    python3 - "$HOME/.config/wezterm/colors/$k.toml" <<'PY' && ok || bad "$k.toml is not valid TOML / shape"
import sys, tomllib
d = tomllib.load(open(sys.argv[1], "rb"))
c = d["colors"]
assert len(c["ansi"]) == 8 and len(c["brights"]) == 8
assert all(v.startswith("#") for v in c["ansi"] + c["brights"])
PY
  done
else
  echo "   (python3 tomllib not available, TOML parse skipped)"
fi
if command -v nvim >/dev/null 2>&1; then
  cat > "$SANDBOX/chk.lua" <<'LUA'
local M = dofile(arg[1])
local n = 0
for _ in pairs(M.themes) do n = n + 1 end
local ef = M.themes["everforest"]
io.write(n, "|", type(ef) == "table" and ef.dark or tostring(ef), "|", type(ef) == "table" and ef.light or "", "\n")
LUA
  res=$(nvim -u NONE -l "$SANDBOX/chk.lua" "$HOME/.wezterm_themes.lua" 2>&1)
  eq "${res%%|*}" "$(registry_list | wc -l | tr -d ' ')" "entries in ~/.wezterm_themes.lua ($res)"
  case "$res" in *"|"*"|"*) ok ;; *) bad "wezterm_themes.lua did not load: $res" ;; esac
else
  grep -q '^return M' "$HOME/.wezterm_themes.lua" && ok || bad "wezterm_themes.lua malformed"
fi
# every registry theme is listed, and no null leaks into the lua map
for t in $(registry_list); do grep -q "\[\"$t\"\] =" "$HOME/.wezterm_themes.lua" && ok || bad "$t missing in wezterm_themes.lua"; done
grep -q 'null' "$HOME/.wezterm_themes.lua" && bad "null in wezterm_themes.lua" || ok

step "B4. generate hooks: stale files removed, failure changes nothing"
echo x > "$THEMES_GENERATED/ghostty/ghost.conf"; echo x > "$HOME/.config/wezterm/colors/ghost.toml"
"$MT/bin/theme-generate" --no-apply >/dev/null 2>&1
[ -e "$THEMES_GENERATED/ghostty/ghost.conf" ] && bad "stale ghostty conf not removed" || ok
[ -e "$HOME/.config/wezterm/colors/ghost.toml" ] && bad "stale wezterm scheme not removed" || ok
before=$(tree_sum "$THEMES_GENERATED/ghostty"; tree_sum "$HOME/.config/wezterm"; cat "$HOME/.wezterm_themes.lua")
mkdir "$SANDBOX/badreg"; cp "$MT"/registry/*.yaml "$SANDBOX/badreg/"
echo 'mode: bogus' > "$SANDBOX/badreg/gruvbox.yaml"
THEMES_REGISTRY="$SANDBOX/badreg" "$MT/hooks/generate.d/50-mac-ghostty" >/dev/null 2>&1; r1=$?
THEMES_REGISTRY="$SANDBOX/badreg" "$MT/hooks/generate.d/50-mac-wezterm" >/dev/null 2>&1; r2=$?
[ $r1 -ne 0 ] && [ $r2 -ne 0 ] && ok || bad "hooks should fail on a broken registry ($r1/$r2)"
after=$(tree_sum "$THEMES_GENERATED/ghostty"; tree_sum "$HOME/.config/wezterm"; cat "$HOME/.wezterm_themes.lua")
[ "$before" = "$after" ] && ok || bad "failed hook run modified output"
rm -rf "$SANDBOX/badreg"

# ----------------------------------------------------------------------------
step "B5. apply hooks on theme-switch (ghostty current-colors, config touch, wezterm touch)"
mkdir -p "$HOME/.config/ghostty"
SW="$MT/bin/theme-switch"
"$SW" gruvbox >/dev/null 2>&1
cmp -s "$HOME/.config/ghostty/current-colors.conf" "$THEMES_GENERATED/ghostty/gruvbox.conf" && ok || bad "current-colors.conf != ghostty/gruvbox.conf"
[ -e "$HOME/.config/ghostty/config" ] && bad "ghostty config must never be created" || ok
"$SW" everforest >/dev/null 2>&1
cmp -s "$HOME/.config/ghostty/current-colors.conf" "$THEMES_GENERATED/ghostty/everforest-dark.conf" && ok || bad "adaptive: current-colors.conf != everforest-dark"
"$SW" light >/dev/null 2>&1
th=$(cat "$HOME/.theme_light"); theme_meta "$th"
if [ "$T_mode" = adaptive ]; then k="$th-light"; else k="$th"; fi
cmp -s "$HOME/.config/ghostty/current-colors.conf" "$THEMES_GENERATED/ghostty/$k.conf" && ok || bad "light: current-colors.conf != $k"
eq "$(cat "$HOME/.bg_mode")" light "bg_mode after 'light'"
"$SW" dark >/dev/null 2>&1; "$SW" gruvbox >/dev/null 2>&1

# config is touched (mtime bumped), but only when present
: > "$HOME/.config/ghostty/config"; touch -t 200001010000 "$HOME/.config/ghostty/config"
old=$(ls -l --time-style=+%s "$HOME/.config/ghostty/config" 2>/dev/null | awk '{print $6}')
[ -z "$old" ] && old=$(stat -f %m "$HOME/.config/ghostty/config")
"$SW" --apply >/dev/null 2>&1
new=$(ls -l --time-style=+%s "$HOME/.config/ghostty/config" 2>/dev/null | awk '{print $6}')
[ -z "$new" ] && new=$(stat -f %m "$HOME/.config/ghostty/config")
[ "$new" -gt "$old" ] && ok || bad "ghostty config mtime not bumped ($old -> $new)"
[ ! -s "$HOME/.config/ghostty/config" ] && ok || bad "ghostty config content must never be modified"

# wezterm watches ~/.theme_<mode>: --apply must touch it even when the theme is unchanged
touch -t 200001010000 "$HOME/.theme_dark"
"$SW" --apply >/dev/null 2>&1
[ "$(stat -c %Y "$HOME/.theme_dark" 2>/dev/null || stat -f %m "$HOME/.theme_dark")" -gt 946684800 ] && [ "$(cat "$HOME/.theme_dark")" = gruvbox ] && ok || bad ".theme_dark not touched by wezterm hook"

# generated ghostty file gone -> hook rebuilds it
rm -rf "$THEMES_GENERATED/ghostty"
out=$("$SW" --apply 2>&1); rc=$?
[ $rc -eq 0 ] && [ -s "$THEMES_GENERATED/ghostty/gruvbox.conf" ] && ok || bad "ghostty conf not regenerated (rc=$rc): $out"

# quiet mode really is quiet with the Mac hooks installed
[ -z "$("$SW" --apply -q 2>&1)" ] && ok || bad "--quiet must print nothing (Mac hooks)"
out=$("$SW" --apply 2>&1)
printf '%s' "$out" | grep -q 'ghostty  applied' && printf '%s' "$out" | grep -q 'wezterm  applied' && printf '%s' "$out" | grep -q 'terminals recoloured' && ok || bad "hook status lines missing: $out"

# a failing hook never fails the switch
rm -f "$THEMES_GENERATED/ghostty/gruvbox.conf"
chmod a-w "$HOME/.config/ghostty" 2>/dev/null
mv "$MT/hooks/generate.d/50-mac-ghostty" "$MT/hooks/generate.d/50-mac-ghostty.off"
out=$("$SW" --apply 2>&1); rc=$?
chmod u+w "$HOME/.config/ghostty"
mv "$MT/hooks/generate.d/50-mac-ghostty.off" "$MT/hooks/generate.d/50-mac-ghostty"
[ $rc -eq 0 ] && ok || bad "a failing hook must not fail theme-switch (rc=$rc)"
printf '%s' "$out" | grep -q 'failed (continuing)' && ok || bad "failing hook should warn: $out"
"$SW" --apply -q >/dev/null 2>&1

# ----------------------------------------------------------------------------
step "B6. OSC hook: recolours the PTYs under the terminal app only"
T="$SANDBOX/ttys"; mkdir -p "$T"; : > "$T/a"; : > "$T/b"; : > "$T/c"; : > "$T/d"; : > "$T/e"; : > "$T/ro"
chmod a-w "$T/ro"
cat > "$SANDBOX/ps.txt" <<PS
  100     1 ??
  101   100 a
  102   101 a
  103   100 b
  104   103 c
  200     1 ??
  201   200 d
  202   201 ro
  300     1 e
  400   300 e
PS
# expected payload, built independently of the hook from the registry
exp_payload() {
  local th="$1" bgm="$2" i=0 n v
  printf '\033]12;%s\007' "$(reg "$th" "$bgm" colors cursor)"
  for n in black red green yellow blue magenta cyan white bright_black bright_red bright_green bright_yellow bright_blue bright_magenta bright_cyan bright_white; do
    printf '\033]4;%s;%s\007' "$i" "$(reg "$th" "$bgm" colors "$n")"; i=$((i + 1))
  done
  printf '\033]10;%s\007\033]11;%s\007\033]12;%s\007' "$(reg "$th" "$bgm" colors foreground)" "$(reg "$th" "$bgm" colors background)" "$(reg "$th" "$bgm" colors cursor)"
}
exp_payload gruvbox dark > "$SANDBOX/exp.bin"
osc() {
  THEMES_PS_TABLE="$SANDBOX/ps.txt" THEMES_TERMINAL_PIDS="100 200" THEMES_TTY_PREFIX="$T/" \
    THEME=gruvbox BG_MODE=dark THEME_KEY=gruvbox THEMES_ROOT="$MT" THEMES_QUIET=${QUIET:-0} "$@" "$MT/hooks/apply.d/60-mac-terminal-osc"
}
out=$(THEMES_CURRENT_TTY="$T/b" osc env 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "osc hook rc=$rc: $out"
cmp -s "$T/a" "$SANDBOX/exp.bin" && ok || bad "tty a: payload differs"
cmp -s "$T/c" "$SANDBOX/exp.bin" && ok || bad "tty c (nested): payload differs"
cmp -s "$T/d" "$SANDBOX/exp.bin" && ok || bad "tty d (wezterm): payload differs"
[ -s "$T/b" ] && bad "caller tty b must be skipped" || ok
[ -s "$T/e" ] && bad "tty e is outside the terminal app tree" || ok
[ -s "$T/ro" ] && bad "unwritable tty written?" || ok
printf '%s' "$out" | grep -q 'terminals recoloured: 3' && ok || bad "should report 3 terminals: $out"
# the cursor sequence comes first, and again last
eq "$(head -c 5 "$T/a" | od -An -tx1 | tr -d ' \n')" 1b5d31323b "payload starts with ESC ] 12 ;"
eq "$(tr -cd '\007' < "$T/a" | wc -c | tr -d ' ')" 20 "BEL terminators (cursor + 16 palette + fg/bg/cursor)"
# dedup: tty a hosts two processes but is written once
eq "$(wc -c < "$T/a" | tr -d ' ')" "$(wc -c < "$SANDBOX/exp.bin" | tr -d ' ')" "tty a written exactly once"

: > "$T/a"; : > "$T/b"; : > "$T/c"; : > "$T/d"
THEMES_CURRENT_TTY="$T/b" THEMES_OSC_CALLER_TTY=1 osc env >/dev/null 2>&1
cmp -s "$T/b" "$SANDBOX/exp.bin" && ok || bad "THEMES_OSC_CALLER_TTY=1 should include the caller tty"

: > "$T/a"; : > "$T/b"; : > "$T/c"; : > "$T/d"
out=$(THEMES_CURRENT_TTY="$T/b" THEMES_OSC_CURRENT=1 osc env 2>&1)
printf '%s' "$out" | grep -q 'terminals recoloured' && ok || bad "THEMES_OSC_CURRENT output: $out"
out=$(TMUX=x THEMES_CURRENT_TTY="$T/b" THEMES_OSC_CURRENT=1 osc env 2>&1 | od -An -tx1 | tr -d ' \n')
case "$out" in *1b50746d75783b1b1b5d31323b*) ok ;; *) bad "tmux DCS passthrough wrapper missing" ;; esac

: > "$T/a"
out=$(THEMES_PS_TABLE="$SANDBOX/ps.txt" THEMES_TERMINAL_PIDS="999" THEMES_TTY_PREFIX="$T/" THEME=gruvbox BG_MODE=dark THEMES_ROOT="$MT" "$MT/hooks/apply.d/60-mac-terminal-osc" 2>&1); rc=$?
[ $rc -eq 0 ] && printf '%s' "$out" | grep -q 'recoloured: 0' && [ ! -s "$T/a" ] && ok || bad "unknown terminal pid should be a quiet no-op (rc=$rc): $out"
out=$(THEMES_PS_TABLE="$SANDBOX/ps.txt" THEMES_TERMINAL_PIDS="" THEMES_TTY_PREFIX="$T/" THEME=gruvbox BG_MODE=dark THEMES_ROOT="$MT" "$MT/hooks/apply.d/60-mac-terminal-osc" 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "no terminal running should not fail (rc=$rc): $out"

# through theme-switch: fixture env is inherited, adaptive theme uses its mode variant
: > "$T/a"
THEMES_PS_TABLE="$SANDBOX/ps.txt" THEMES_TERMINAL_PIDS="100 200" THEMES_TTY_PREFIX="$T/" THEMES_CURRENT_TTY=/dev/null "$SW" everforest >/dev/null 2>&1
exp_payload everforest dark > "$SANDBOX/exp2.bin"
cmp -s "$T/a" "$SANDBOX/exp2.bin" && ok || bad "theme-switch everforest: tty a payload differs (adaptive variant)"
"$SW" gruvbox -q >/dev/null 2>&1

# ----------------------------------------------------------------------------
step "B7. comparison with the old ghostty/wezterm adapters"
OLD="$(cd "$ROOT/../themes-old" 2>/dev/null && pwd)"
REAL_YQ=$(PATH="$(printf '%s' "$PATH")" command -v yq || true)
if [ "$COMPARE_OLD" != 1 ]; then
  echo "   skipped (pass --compare-old to run it; slow)"
elif [ -n "$REAL_YQ" ] && "$REAL_YQ" --help 2>&1 | grep -qi 'jq wrapper' && [ -d "$OLD/adapters" ]; then
  work=$(mktemp -d); SANDBOXES="$SANDBOXES $work"
  mkdir -p "$work/bin" "$work/home/.config/themes"
  ln -s "$THEMES_REGISTRY" "$work/home/.config/themes/registry"
  cat > "$work/bin/yq" <<SHIM
#!/usr/bin/env bash
case "\$1" in *'{'*) exec "$REAL_YQ" -y "\$@" ;; *) exec "$REAL_YQ" -r "\$@" ;; esac
SHIM
  chmod +x "$work/bin/yq"
  n=0
  for k in $keys; do
    case "$k" in *-dark) t=${k%-dark}; m=dark ;; *-light) t=${k%-light}; m=light ;; *) t=$k; theme_meta "$t"; m=$T_mode ;; esac
    # a fixed-mode theme whose name ends in -dark/-light (none today) would be mis-split; guard it
    if ! registry_file "$t" >/dev/null 2>&1; then t=$k; theme_meta "$t"; m=$T_mode; fi
    for tool in ghostty wezterm; do
      o=$(HOME="$work/home" PATH="$work/bin:$PATH" bash "$OLD/adapters/executable_$tool" "$t" "$m" 2>&1)
      w=$("$MT/adapters/$tool" "$t" "$m" 2>&1)
      if [ "$o" = "$w" ]; then ok; n=$((n + 1)); else
        bad "$tool $t/$m differs from old adapter"; diff <(printf '%s\n' "$o") <(printf '%s\n' "$w") | head -4 >&2
      fi
    done
  done
  echo "   compared $n adapter outputs with the old ghostty/wezterm adapters"
else
  echo "   skipped: python yq or old adapters not available"
fi

# ============================================================================
step "C. bash 3.2 portability of the Mac-only files"
for f in $MAC_FILES; do
  src="$MT/$f"
  bash -n "$src" 2>/dev/null && ok || bad "syntax error in $f"
  if grep -nE '(^|[^[:alnum:]_])(mapfile|readarray|declare -A|local -A|coproc)([^[:alnum:]_]|$)|\$\{[A-Za-z_]+(,,|\^\^)\}|readlink -f|sed -i|[^a-z]timeout [0-9]|\\x1b' "$src" | grep -v '^[0-9]*:[[:space:]]*#' >/dev/null; then
    bad "$f uses a bash-4 / GNU-only construct"
    grep -nE '(^|[^[:alnum:]_])(mapfile|readarray|declare -A|local -A|coproc)([^[:alnum:]_]|$)|readlink -f|sed -i|[^a-z]timeout [0-9]|\\x1b' "$src" >&2
  else ok; fi
done

HOME="$REAL_HOME"
summary
