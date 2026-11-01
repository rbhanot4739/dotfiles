#!/usr/bin/env bash
# Dev-only check for bin/theme-switch (including --mode). Not deployed.
# Runs in a scratch HOME with its own tmux server and a headless Neovim; your real
# state files, tmux server and generated files are never touched.
#
# Usage: bash dev/verify-switch.sh
set -u
. "$(dirname "$0")/common.sh"

deploy_tmp || exit 1
export HOME="$SANDBOX"
export THEMES_GENERATED="$SANDBOX/gen"
export TMUX_TMPDIR="$SANDBOX/tmuxtmp"; mkdir -p "$TMUX_TMPDIR"
NVIM_PID=""
cleanup() {
  tmux kill-server >/dev/null 2>&1
  [ -n "$NVIM_PID" ] && kill "$NVIM_PID" 2>/dev/null
  rm -rf "$SANDBOX"
}
trap cleanup EXIT

SW="$THEMES/bin/theme-switch"
GEN="$THEMES_GENERATED"
. "$THEMES/lib/registry.sh"

bg()    { cat "$HOME/.bg_mode" 2>/dev/null; }
tdark() { cat "$HOME/.theme_dark" 2>/dev/null; }
tlight(){ cat "$HOME/.theme_light" 2>/dev/null; }
reg()   { registry_dump_section "$1" "$2" "$3" | awk -F'\t' -v k="$4" '$1==k {print $2}'; }
eq()    { [ "$1" = "$2" ] && ok || bad "$3: got '$1', expected '$2'"; }

step "0. nothing is installed in your real home"
[ "$HOME" = "$SANDBOX" ] && ok || bad "HOME not sandboxed"

step "1. first run on a fresh host: generates, writes defaults, applies"
start=$(date +%s)
out=$("$SW" --apply 2>&1); rc=$?
elapsed=$(( $(date +%s) - start ))
[ $rc -eq 0 ] && ok || bad "first run failed rc=$rc: $out"
echo "   (${elapsed}s)"; printf '%s\n' "$out" | sed 's/^/   /'
[ -s "$GEN/tmux/tokyonight-night.conf" ] && ok || bad "theme-generate was not run"
eq "$(bg)" dark "bg_mode persisted on a clean state"
eq "$(tdark)" "tokyonight-night" "default dark theme persisted"
for f in fzf/active.opts fzf/active.sh delta/delta-active.gitconfig lazygit/lazygit-active-theme.yml; do
  [ -s "$GEN/$f" ] && ok || bad "missing active file: $f"
done
cmp -s "$GEN/fzf/active.opts" "$GEN/fzf/tokyonight-night.opts" && ok || bad "active.opts != tokyonight-night.opts"
grep -q 'features = tokyonight-night' "$GEN/delta/delta-active.gitconfig" && grep -q 'dark = true' "$GEN/delta/delta-active.gitconfig" && ok || bad "delta-active.gitconfig content"
git config -f "$GEN/delta/delta-active.gitconfig" --get delta.features | grep -qx tokyonight-night && ok || bad "git cannot read delta-active.gitconfig"
ls -A "$GEN" | grep -q '^\.stage' && bad "staging dir left behind" || ok

step "2. switch by name, mode follows the theme"
out=$("$SW" gruvbox 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "switch gruvbox rc=$rc: $out"
eq "$(bg)" dark "bg_mode"; eq "$(tdark)" gruvbox ".theme_dark"
grep -q 'features = gruvbox' "$GEN/delta/delta-active.gitconfig" && ok || bad "delta feature for gruvbox"
cmp -s "$GEN/lazygit/lazygit-active-theme.yml" "$GEN/lazygit/gruvbox.yml" && ok || bad "lazygit active != gruvbox.yml"
cmp -s "$GEN/fzf/active.sh" "$GEN/fzf/gruvbox.sh" && ok || bad "fzf active.sh != gruvbox.sh"

out=$("$SW" tokyonight-day 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "switch tokyonight-day rc=$rc"
printf '%s' "$out" | grep -q 'switching bg_mode to light' && ok || bad "should announce the mode flip"
eq "$(bg)" light "bg_mode flipped"; eq "$(tlight)" tokyonight-day ".theme_light"; eq "$(tdark)" gruvbox ".theme_dark must be untouched"
grep -q 'light = true' "$GEN/delta/delta-active.gitconfig" && ! grep -q 'dark = true' "$GEN/delta/delta-active.gitconfig" && ok || bad "delta light flag"

out=$("$SW" everforest 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "switch everforest (light) rc=$rc"
eq "$(bg)" light "adaptive keeps bg_mode"; eq "$(tlight)" everforest ".theme_light"
grep -q 'features = everforest-light' "$GEN/delta/delta-active.gitconfig" && ok || bad "adaptive delta section (light)"
cmp -s "$GEN/tmux/everforest-light.conf" "$GEN/tmux/everforest-light.conf" && cmp -s "$GEN/lazygit/lazygit-active-theme.yml" "$GEN/lazygit/everforest-light.yml" && ok || bad "adaptive lazygit (light)"

out=$("$SW" dark 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "switch dark rc=$rc"
eq "$(bg)" dark "bg_mode"; eq "$(tdark)" gruvbox "remembered dark theme restored"
grep -q 'features = gruvbox' "$GEN/delta/delta-active.gitconfig" && ok || bad "delta back to gruvbox"
"$SW" everforest >/dev/null 2>&1
grep -q 'features = everforest-dark' "$GEN/delta/delta-active.gitconfig" && ok || bad "adaptive delta section (dark)"
"$SW" light >/dev/null 2>&1
eq "$(bg)" light "switch light"; eq "$(tlight)" everforest "remembered light theme"
"$SW" dark >/dev/null 2>&1

step "3. bad input changes nothing"
before="$(bg)|$(tdark)|$(tlight)"
for a in nope ../x 'a b' sepia; do
  "$SW" "$a" >/dev/null 2>&1 && bad "switch '$a' should fail" || ok
done
"$SW" gruvbox nordfox >/dev/null 2>&1; eq $? 2 "two arguments -> exit 2"
"$SW" --bogus >/dev/null 2>&1; eq $? 2 "unknown option -> exit 2"
"$SW" --apply gruvbox >/dev/null 2>&1; eq $? 2 "--apply with a theme -> exit 2"
"$SW" --list gruvbox >/dev/null 2>&1; eq $? 2 "--list with a theme -> exit 2"
eq "$(bg)|$(tdark)|$(tlight)" "$before" "state after bad input"

step "4. stored theme vanished -> warn, default, persist"
echo no-such-theme > "$HOME/.theme_dark"
out=$("$SW" --apply 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "fallback run rc=$rc"
printf '%s' "$out" | grep -q "no-such-theme' not found" && ok || bad "fallback should warn: $out"
eq "$(tdark)" tokyonight-night "fallback persisted"
"$SW" gruvbox >/dev/null 2>&1

step "5. missing generated file is regenerated"
rm -f "$GEN/tmux/gruvbox.conf"
out=$("$SW" --apply 2>&1); rc=$?
[ $rc -eq 0 ] && [ -s "$GEN/tmux/gruvbox.conf" ] && ok || bad "did not regenerate (rc=$rc): $out"
printf '%s' "$out" | grep -q 'running theme-generate' && ok || bad "should say it is regenerating"

step "6. idempotent, quiet"
before=$(tree_sum "$GEN"); sb="$(bg)|$(tdark)|$(tlight)"
"$SW" --apply -q >/dev/null 2>&1; "$SW" gruvbox -q >/dev/null 2>&1
[ "$before" = "$(tree_sum "$GEN")" ] && eq "$(bg)|$(tdark)|$(tlight)" "$sb" "state" || bad "repeat run changed output"
[ -z "$("$SW" --apply -q 2>&1)" ] && ok || bad "--quiet must print nothing"
ls -A "$HOME" | grep -E '^\.(bg_mode|theme_(dark|light))\.' && bad "temp files left in HOME" || ok

step "7. tmux: no server -> skipped and no server started; running server -> applied"
out=$("$SW" --apply 2>&1)
printf '%s' "$out" | grep -q 'tmux .*no server running' && ok || bad "should skip tmux without a server: $out"
tmux list-sessions >/dev/null 2>&1 && bad "theme-switch must not start a tmux server" || ok
tmux -f /dev/null new-session -d -s v </dev/null
"$SW" gruvbox >/dev/null 2>&1
eq "$(tmux show -gv @DEFAULT_BG)" "$(reg gruvbox dark tmux default_bg)" "@DEFAULT_BG (gruvbox)"
"$SW" everforest >/dev/null 2>&1
eq "$(tmux show -gv @DEFAULT_BG)" "$(reg everforest dark tmux default_bg)" "@DEFAULT_BG (everforest dark)"
"$SW" tokyonight-day >/dev/null 2>&1
eq "$(tmux show -gv @DEFAULT_BG)" "$(reg tokyonight-day light tmux default_bg)" "@DEFAULT_BG (tokyonight-day)"
tmux show -gv @fzf-url-fzf-options | grep -q -- '--color=bg:' && ok || bad "@fzf-url-fzf-options missing colours"
tmux show -gv @fzf-url-fzf-options | grep -q -- '--tmux center,100%,50%' && ok || bad "@fzf-url-fzf-options base options"
"$SW" dark >/dev/null 2>&1; "$SW" gruvbox >/dev/null 2>&1

step "8. neovim instances are asked to reload (headless nvim + nvr)"
if command -v nvim >/dev/null 2>&1 && command -v nvr >/dev/null 2>&1; then
  nvim --headless -u NONE --listen "$SANDBOX/nvim.sock" \
    -c "lua function Load_colorscheme() local f=io.open('$SANDBOX/nvim-marker','a'); f:write('x'); f:close() end" >/dev/null 2>&1 &
  NVIM_PID=$!
  for _ in 1 2 3 4 5 6 7 8 9 10; do [ -S "$SANDBOX/nvim.sock" ] && break; sleep 0.3; done
  rm -f "$SANDBOX/nvim-marker"
  THEMES_SKIP_NVIM=1 "$SW" nordfox >/dev/null 2>&1; sleep 1
  [ ! -e "$SANDBOX/nvim-marker" ] && ok || bad "THEMES_SKIP_NVIM=1 must skip nvim"
  "$SW" gruvbox >/dev/null 2>&1
  for _ in 1 2 3 4 5 6 7 8 9 10; do [ -s "$SANDBOX/nvim-marker" ] && break; sleep 0.4; done
  [ -s "$SANDBOX/nvim-marker" ] && ok || bad "nvim did not receive Load_colorscheme()"
  kill "$NVIM_PID" 2>/dev/null; NVIM_PID=""
  start=$(date +%s); "$SW" nordfox >/dev/null 2>&1; [ $(( $(date +%s) - start )) -le 3 ] && ok || bad "switch with a dead nvim socket blocked"
else
  echo "   skipped (nvim/nvr not installed)"
fi

step "9. apply.d hooks"
mkdir -p "$THEMES/hooks/apply.d"
cat > "$THEMES/hooks/apply.d/50-test" <<'EOF'
#!/usr/bin/env bash
echo "$THEME|$BG_MODE|$THEME_KEY" > "$THEMES_GENERATED/hook-ran"
EOF
printf '#!/usr/bin/env bash\nexit 3\n' > "$THEMES/hooks/apply.d/60-fails"
printf '#!/usr/bin/env bash\ntouch "$THEMES_GENERATED/should-not-exist"\n' > "$THEMES/hooks/apply.d/70-not-executable"
chmod +x "$THEMES/hooks/apply.d/50-test" "$THEMES/hooks/apply.d/60-fails"
out=$("$SW" everforest 2>&1); rc=$?
[ $rc -eq 0 ] && ok || bad "failing hook must not fail the switch (rc=$rc)"
eq "$(cat "$GEN/hook-ran" 2>/dev/null)" "everforest|dark|everforest-dark" "hook environment"
printf '%s' "$out" | grep -q '60-fails failed' && ok || bad "failing hook should warn"
[ ! -e "$GEN/should-not-exist" ] && ok || bad "non-executable hook ran"
rm -rf "$THEMES/hooks" "$GEN/hook-ran"; "$SW" gruvbox >/dev/null 2>&1

step "10. --list and no-terminal behaviour"
list=$("$SW" --list 2>&1)
n=$(registry_list | wc -l | tr -d ' ')
eq "$(printf '%s\n' "$list" | grep -vc '^#')" "$n" "one line per registry theme"
for t in $(registry_list); do printf '%s\n' "$list" | grep -q "[ ]$t[ ]" && ok || bad "$t missing from --list"; done
printf '%s\n' "$list" | grep -E '^ ?\* +gruvbox ' >/dev/null && ok || bad "active theme not marked with *"
printf '%s\n' "$list" | grep -E '^ ?\+ +tokyonight-day ' >/dev/null && ok || bad "other-mode theme not marked with +"
first=$(printf '%s\n' "$list" | grep -v '^#' | head -1)
printf '%s' "$first" | grep -qE ' (dark|adaptive) ' && ok || bad "current-mode themes should be listed first: $first"
printf '%s\n' "$list" | head -1 | grep -q '^# bg_mode: dark' && ok || bad "header line"
nolist=$("$SW" </dev/null 2>&1 | cat); eq "$nolist" "$list" "no terminal, no args -> list"
eq "$(bg)|$(tdark)" "dark|gruvbox" "listing must not change state"

step "11. theme-switch --mode (command line)"
"$SW" --mode light >/dev/null 2>&1; eq "$(bg)" light "--mode light"
"$SW" --mode dark  >/dev/null 2>&1; eq "$(bg)" dark  "--mode dark"
out=$("$SW" -q --mode light 2>&1); eq "$out|$(bg)" "|light" "-q --mode light is silent and works"
"$SW" --mode dark -q >/dev/null 2>&1; eq "$(bg)" dark "--mode dark -q (order of options)"
"$SW" --mode purple >/dev/null 2>&1; eq $? 2 "--mode purple -> exit 2"
"$SW" --mode gruvbox >/dev/null 2>&1; eq $? 2 "--mode <theme> -> exit 2"
"$SW" --mode --apply >/dev/null 2>&1; eq $? 2 "--mode --apply -> exit 2"
"$SW" --mode --list >/dev/null 2>&1; eq $? 2 "--mode --list -> exit 2"
eq "$("$SW" --mode </dev/null | cat)" dark "--mode without a terminal prints the mode"
"$SW" --help | grep -q -- '--mode' && ok || bad "--help does not mention --mode"
eq "$("$SW" --help | tail -1 | cut -c1-1)" "S" "--help ends at the last comment line"

step "12. interactive popups (fzf in a pseudo-terminal, auto-selected)"
if command -v fzf >/dev/null 2>&1 && script --version 2>&1 | grep -q util-linux; then
  pty() { # <FZF_DEFAULT_OPTS> <cmd>...
    local o="$1"; shift
    FZF_DEFAULT_OPTS="$o" run_limited 30 script -qec "$*" /dev/null </dev/null >"$SANDBOX/pty.out" 2>&1
  }
  pty "--query=nordfox --exact --select-1" "$SW"
  eq "$(bg)|$(tdark)" "dark|nordfox" "popup picked nordfox"
  pty "--query=rose-pine-dawn --exact --select-1" "$SW"
  eq "$(bg)|$(tlight)" "light|rose-pine-dawn" "popup picked a light theme -> mode flips"
  before="$(bg)|$(tdark)|$(tlight)"
  pty "--bind=start:abort" "$SW"
  eq "$(bg)|$(tdark)|$(tlight)" "$before" "cancelled popup changes nothing"
  pty "--query=light --exact --select-1" "$SW" --mode
  eq "$(bg)|$(tlight)" "light|rose-pine-dawn" "--mode popup picked light"
  pty "--query=dark --exact --select-1" "$SW" --mode
  eq "$(bg)|$(tdark)" "dark|nordfox" "--mode popup picked dark"
  pty "--bind=start:abort" "$SW" --mode
  eq "$(bg)" dark "cancelled --mode popup changes nothing"
  grep -q 'Theme: ' "$SANDBOX/pty.out" 2>/dev/null || true
else
  echo "   skipped (needs fzf and util-linux script)"
fi

step "13. bash 3.2 portability scan (lib, bin, adapters)"
scan=$(grep -rnE 'declare -A|typeset -A|local -A|mapfile|readarray|\$\{[A-Za-z_]+(,,|\^\^|@[QEPAa])\}|&>>|\|&|;;&|coproc|local -n|declare -n|\[\[ -v |readlink -f|sed -i|\btimeout [0-9]' \
  "$ROOT/lib" "$ROOT/adapters" "$ROOT/bin" 2>/dev/null | grep -v 'lib/tmux/')
[ -z "$scan" ] && ok || { bad "bash-4/GNU-only constructs:"; echo "$scan" >&2; }

summary
