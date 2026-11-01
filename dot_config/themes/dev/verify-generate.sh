#!/usr/bin/env bash
# Dev-only check for lib/state.sh and bin/theme-generate. Not deployed.
# Installs themes into a scratch HOME exactly like `chezmoi apply` would and runs
# everything there; your real ~/.config and ~/.bg_mode etc. are never touched.
#
# Usage: bash dev/verify-generate.sh
set -u
. "$(dirname "$0")/common.sh"

deploy_tmp || exit 1
trap 'rm -rf "$SANDBOX"' EXIT
export HOME="$SANDBOX"
GEN="$SANDBOX/gen"
export THEMES_GENERATED="$GEN"
GENERATE="$THEMES/bin/theme-generate"

step "0. deployment shape (chezmoi naming, exec bits, dev/ not deployed)"
for f in bin/theme-generate adapters/tmux adapters/fzf adapters/delta adapters/lazygit; do
  [ -x "$THEMES/$f" ] && ok || bad "$f missing or not executable in deployed tree"
done
for f in lib/registry.sh lib/registry.awk lib/state.sh registry/everforest.yaml lib/tmux/session_context.sh; do
  [ -f "$THEMES/$f" ] && ok || bad "$f missing in deployed tree"
done
[ ! -e "$THEMES/dev" ] && ok || bad "dev/ must not be deployed"
find "$THEMES" -name 'executable_*' | grep -q . && bad "undeployed executable_ names found" || ok

# expected output set, from the registry itself
. "$THEMES/lib/registry.sh"
nk=0; keys=""
for t in $(registry_list); do
  theme_meta "$t" || { bad "theme_meta $t"; continue; }
  if [ "$T_mode" = adaptive ]; then ks="$t-dark $t-light"; else ks="$t"; fi
  for k in $ks; do keys="$keys $k"; nk=$((nk + 1)); done
done

step "1. theme-generate: full output set"
start=$(date +%s)
out=$("$GENERATE" --no-apply 2>&1); rc=$?
elapsed=$(( $(date +%s) - start ))
[ $rc -eq 0 ] && ok || bad "theme-generate exited $rc: $out"
echo "   $out  (${elapsed}s)"
[ "$elapsed" -le 15 ] && ok || bad "theme-generate too slow: ${elapsed}s"
for k in $keys; do
  for f in "fzf/$k.sh" "fzf/$k.opts" "tmux/$k.conf" "lazygit/$k.yml" "delta/sections/$k.gitconfig"; do
    [ -s "$GEN/$f" ] && ok || bad "missing or empty: $f"
  done
done
[ -s "$GEN/delta/delta-themes.gitconfig" ] && ok || bad "missing delta-themes.gitconfig"
total=$(find "$GEN" -type f | wc -l | tr -d ' ')
expected=$(( nk * 5 + 1 ))
[ "$total" -eq "$expected" ] && ok || bad "unexpected file count: $total (expected $expected)"
ls -A "$GEN" | grep -q '^\.stage' && bad "staging dir left behind" || ok

step "2. generated content is usable"
[ "$(git config -f "$GEN/delta/delta-themes.gitconfig" --list | wc -l | tr -d ' ')" = $(( nk * 11 )) ] && ok || bad "delta aggregate: wrong number of keys"
[ "$(grep -c '^\[delta ' "$GEN/delta/delta-themes.gitconfig")" = "$nk" ] && ok || bad "delta aggregate: wrong number of sections"
grep -q 'everforest-dark' "$GEN/delta/delta-themes.gitconfig" && grep -q 'everforest-light' "$GEN/delta/delta-themes.gitconfig" && ok || bad "adaptive delta sections missing"
[ -f "$GEN/tmux/everforest-dark.conf" ] && [ ! -f "$GEN/tmux/everforest.conf" ] && ok || bad "adaptive naming (-dark/-light only)"
[ -f "$GEN/tmux/gruvbox.conf" ] && [ ! -f "$GEN/tmux/gruvbox-dark.conf" ] && ok || bad "single-mode naming (plain name only)"
if command -v tmux >/dev/null 2>&1; then
  export TMUX_TMPDIR="$SANDBOX"
  run_limited 10 tmux -L vg -f /dev/null new-session -d -s v </dev/null >/dev/null 2>&1
  bad_conf=0
  for f in "$GEN"/tmux/*.conf; do run_limited 10 tmux -L vg source-file "$f" </dev/null >/dev/null 2>&1 || { bad_conf=1; bad "tmux rejected ${f##*/}"; }; done
  [ $bad_conf = 0 ] && ok
  run_limited 10 tmux -L vg kill-server </dev/null >/dev/null 2>&1; unset TMUX_TMPDIR
fi
if command -v yq >/dev/null 2>&1 && yq --help 2>&1 | grep -qi 'jq wrapper'; then
  yq -e '.gui.theme.activeBorderColor[0]' "$GEN/lazygit/tokyonight-night.yml" >/dev/null 2>&1 && ok || bad "lazygit yml not valid YAML"
fi

step "3. idempotent"
before=$(tree_sum "$GEN")
"$GENERATE" --no-apply --quiet || bad "second run failed"
[ "$before" = "$(tree_sum "$GEN")" ] && ok || bad "second run changed the output"

step "4. stale files removed, active files preserved"
mkdir -p "$GEN/lazygit" "$GEN/delta" "$GEN/fzf"
echo ghost > "$GEN/fzf/ghost.sh"; echo ghost > "$GEN/tmux/ghost.conf"; echo ghost > "$GEN/delta/sections/ghost.gitconfig"
echo A > "$GEN/fzf/active.opts"; echo B > "$GEN/fzf/active.sh"
echo C > "$GEN/lazygit/lazygit-active-theme.yml"; echo D > "$GEN/delta/delta-active.gitconfig"
"$GENERATE" --no-apply --quiet || bad "run with stale files failed"
[ ! -e "$GEN/fzf/ghost.sh" ] && [ ! -e "$GEN/tmux/ghost.conf" ] && [ ! -e "$GEN/delta/sections/ghost.gitconfig" ] && ok || bad "stale files not removed"
grep -q ghost "$GEN/delta/delta-themes.gitconfig" && bad "stale section leaked into aggregate" || ok
[ "$(cat "$GEN/fzf/active.opts")$(cat "$GEN/fzf/active.sh")$(cat "$GEN/lazygit/lazygit-active-theme.yml")$(cat "$GEN/delta/delta-active.gitconfig")" = "ABCD" ] && ok || bad "active files were modified or removed"
rm -f "$GEN/fzf/active.opts" "$GEN/fzf/active.sh" "$GEN/lazygit/lazygit-active-theme.yml" "$GEN/delta/delta-active.gitconfig"

step "5. a broken theme aborts everything and changes nothing"
cp -R "$THEMES/registry" "$SANDBOX/badreg"
grep -v 'prefix_indicator' "$THEMES/registry/gruvbox.yaml" > "$SANDBOX/badreg/gruvbox.yaml"
sed 's/^mode: dark/mode: sepia/' "$THEMES/registry/nordfox.yaml" > "$SANDBOX/badreg/nordfox.yaml"
before=$(tree_sum "$GEN")
out=$(THEMES_REGISTRY="$SANDBOX/badreg" "$GENERATE" --no-apply 2>&1); rc=$?
[ $rc -ne 0 ] && ok || bad "broken registry should fail"
printf '%s' "$out" | grep -q 'gruvbox' && printf '%s' "$out" | grep -q 'nordfox' && ok || bad "all broken themes should be reported: $out"
printf '%s' "$out" | grep -q 'prefix_indicator' && ok || bad "error should name the missing key"
[ "$before" = "$(tree_sum "$GEN")" ] && ok || bad "generated tree changed despite failure"
ls -A "$GEN" | grep -q '^\.stage' && bad "staging dir left behind after failure" || ok
EMPTY="$SANDBOX/emptyreg"; mkdir -p "$EMPTY"
THEMES_REGISTRY="$EMPTY" "$GENERATE" --no-apply >/dev/null 2>&1 && bad "empty registry should fail" || ok
"$GENERATE" --bogus >/dev/null 2>&1; [ $? -eq 2 ] && ok || bad "unknown option should exit 2"

step "6. generate.d hooks"
mkdir -p "$THEMES/hooks/generate.d"
cat > "$THEMES/hooks/generate.d/50-test" <<'EOF'
#!/usr/bin/env bash
echo "$THEMES_GENERATED|$THEMES_REGISTRY|$THEMES_ROOT" > "$THEMES_GENERATED/hook-ran"
EOF
printf '#!/usr/bin/env bash\nexit 3\n' > "$THEMES/hooks/generate.d/60-fails"
printf '#!/usr/bin/env bash\ntouch "$THEMES_GENERATED/should-not-exist"\n' > "$THEMES/hooks/generate.d/70-not-executable"
chmod +x "$THEMES/hooks/generate.d/50-test" "$THEMES/hooks/generate.d/60-fails"
out=$("$GENERATE" --no-apply 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "a failing hook must not fail theme-generate (rc=$rc)"
[ "$(cat "$GEN/hook-ran" 2>/dev/null)" = "$GEN|$THEMES/registry|$THEMES" ] && ok || bad "hook did not run with the expected environment"
printf '%s' "$out" | grep -q '60-fails failed' && ok || bad "failing hook should warn"
[ ! -e "$GEN/should-not-exist" ] && ok || bad "non-executable hook was run"
rm -rf "$THEMES/hooks" "$GEN/hook-ran"

step "7. lib/state.sh"
S="$SANDBOX/state"; mkdir -p "$S"
state_unit() { ( export THEMES_STATE_DIR="$S"; . "$THEMES/lib/state.sh"; "$@" ); }
state_resolved() { ( export THEMES_STATE_DIR="$S"; . "$THEMES/lib/state.sh"; state_resolve; echo "$BG_MODE $THEME $THEME_FALLBACK" ); }

rm -f "$S"/.bg_mode "$S"/.theme_*
[ "$(state_resolved)" = "dark tokyonight-night 1" ] && ok || bad "no state files -> dark default: $(state_resolved)"
echo light > "$S/.bg_mode"
[ "$(state_resolved)" = "light tokyonight-day 1" ] && ok || bad "light default: $(state_resolved)"
printf '  light \n\n' > "$S/.bg_mode"; printf ' gruvbox\n' > "$S/.theme_light"
[ "$(state_resolved)" = "light gruvbox 0" ] && ok || bad "whitespace trimmed, stored theme used: $(state_resolved)"
echo purple > "$S/.bg_mode"; echo everforest > "$S/.theme_dark"
[ "$(state_resolved)" = "dark everforest 0" ] && ok || bad "invalid bg_mode -> dark: $(state_resolved)"
echo no-such-theme > "$S/.theme_dark"
[ "$(state_resolved)" = "dark tokyonight-night 1" ] && ok || bad "unknown stored theme -> fallback: $(state_resolved)"
echo '../../etc/passwd' > "$S/.theme_dark"
[ "$(state_resolved)" = "dark tokyonight-night 1" ] && ok || bad "path-like theme name rejected: $(state_resolved)"
printf '%s' 'gruvbox' > "$S/.theme_dark"   # no trailing newline
[ "$(state_resolved)" = "dark gruvbox 0" ] && ok || bad "file without trailing newline: $(state_resolved)"

state_unit state_set_bg_mode light && [ "$(cat "$S/.bg_mode")" = light ] && ok || bad "state_set_bg_mode"
state_unit state_set_bg_mode sepia 2>/dev/null && bad "state_set_bg_mode should reject sepia" || ok
state_unit state_set_theme dark nordfox && [ "$(cat "$S/.theme_dark")" = nordfox ] && ok || bad "state_set_theme"
state_unit state_set_theme dark '../x' 2>/dev/null && bad "state_set_theme should reject ../x" || ok
state_unit state_set_theme sepia nordfox 2>/dev/null && bad "state_set_theme should reject mode sepia" || ok
[ "$(ls -A "$S" | grep -c .)" = 3 ] && ok || bad "temp files left behind in state dir: $(ls -A "$S")"
perm=$(ls -l "$S/.bg_mode" | cut -c1-10); [ "$perm" = "-rw-r--r--" ] && ok || bad "state file permissions: $perm"

gen_check() { ( export THEMES_STATE_DIR="$S" THEMES_GENERATED="$GEN"; . "$THEMES/lib/state.sh"; THEME=$1 BG_MODE=$2; gen_find "$3" "$4" ); }
[ "$(gen_check everforest light tmux conf)" = "$GEN/tmux/everforest-light.conf" ] && ok || bad "gen_find adaptive"
[ "$(gen_check gruvbox dark tmux conf)" = "$GEN/tmux/gruvbox.conf" ] && ok || bad "gen_find single-mode"
[ "$(gen_check tokyonight-day dark tmux conf)" = "$GEN/tmux/tokyonight-day.conf" ] && ok || bad "gen_find single-mode with mismatched bg"
gen_check nope dark tmux conf >/dev/null 2>&1 && bad "gen_find should fail for unknown theme" || ok

step "8. bash 3.2 portability scan (lib, bin, adapters)"
scan=$(grep -rnE 'declare -A|typeset -A|local -A|mapfile|readarray|\$\{[A-Za-z_]+(,,|\^\^|@[QEPAa])\}|&>>|\|&|;;&|coproc|local -n|declare -n|\[\[ -v |readlink -f|sed -i|\btimeout [0-9]' \
  "$ROOT/lib" "$ROOT/adapters" "$ROOT/bin" 2>/dev/null | grep -v 'lib/tmux/')
[ -z "$scan" ] && ok || { bad "bash-4/GNU-only constructs:"; echo "$scan" >&2; }

summary
