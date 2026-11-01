#!/usr/bin/env bash
# Dev-only end-to-end check of everything that CONSUMES the theme setup: .zprofile (PATH,
# FZF_DEFAULT_OPTS_FILE), fzf config + wrapper, tmux.conf + tmux-layout.conf, the tmux
# session scripts, delta, lazygit and the zsh widget. Not deployed.
#
# It works on a COPY of the chezmoi source (without the themes-old reference folder) that is
# applied into a scratch HOME with the real chezmoi; your real home, tmux server and state
# files are never touched.
#
# Usage: bash dev/verify-consumers.sh
set -u
. "$(dirname "$0")/common.sh"

command -v chezmoi >/dev/null 2>&1 || { echo "chezmoi is required" >&2; exit 1; }

REAL_HOME="$HOME"
W=$(mktemp -d)
SB="$W/home"; SRC="$W/src"
mkdir -p "$SB/.config" "$SRC"
export TMUX_TMPDIR="$W/tmux"; mkdir -p "$TMUX_TMPDIR"
cleanup() { tmux kill-server >/dev/null 2>&1; HOME="$REAL_HOME"; rm -rf "$W"; }
trap cleanup EXIT

eq()  { [ "$1" = "$2" ] && ok || bad "$3: got '$1', expected '$2'"; }
has() { printf '%s' "$1" | grep -q -- "$2" && ok || bad "$3: missing '$2' in: $(printf '%s' "$1" | head -c 300)"; }
lacks() { printf '%s' "$1" | grep -q -- "$2" && bad "$3: unexpected '$2'" || ok; }

step "0. copy of the chezmoi source"
( cd "$REPO" && tar --exclude=.git --exclude=./dot_config/themes-old -cf - . ) | tar -xf - -C "$SRC"
# An unrelated duplicate in the source (nvim theme-imports.lua next to private_theme-imports.lua)
# makes chezmoi refuse to apply anything; keep this check independent of it.
dup="$SRC/dot_config/nvim/lua/plugins/private_rbhanot"
[ -f "$dup/theme-imports.lua" ] && [ -f "$dup/private_theme-imports.lua" ] && rm -f "$dup/theme-imports.lua"
[ -d "$SRC/dot_config/themes/bin" ] && ok || bad "no themes dir in the copy"

step "1. chezmoi apply into a scratch HOME (Linux data)"
DATA='{"is_mac":false,"is_linux":true,"is_linux_work":false}'
targets=""
for t in .zprofile .tmux.conf .gitconfig .delta-gitconfig custom_config.zsh .config/fzf .config/lazygit .config/themes scripts; do
  targets="$targets $SB/$t"
done
# shellcheck disable=SC2086
chezmoi --source "$SRC" --destination "$SB" --override-data "$DATA" --persistent-state "$W/state.boltdb" \
  --force apply $targets >"$W/apply.log" 2>&1 && ok || { bad "chezmoi apply failed"; cat "$W/apply.log" >&2; }
export HOME="$SB"
export THEMES_SKIP_NVIM=1
T="$SB/.config/themes"
for f in bin/theme-switch bin/theme-generate adapters/tmux adapters/fzf adapters/delta adapters/lazygit; do
  [ -x "$T/$f" ] && ok || bad "not deployed / not executable: $f"
done
[ -f "$T/tmux-layout.conf" ] && [ -f "$T/README.md" ] && [ -f "$T/lib/tmux/session_context.sh" ] && [ -f "$T/lib/tmux/load_theme.sh" ] && ok || bad "layout/README/session_context missing"
find "$T" -name 'executable_*' | grep -q . && bad "deployed files still carry an executable_ prefix" || ok
for f in bin/theme-list bin/theme-monitor bin/theme-notify bin/theme-notify.swift bin/theme-import bin/delta-pager lib/resolve-theme.sh; do
  [ -e "$T/$f" ] && bad "old file deployed: $f" || ok
done
[ -e "$T/dev" ] && bad "dev/ must not be deployed" || ok
[ -e "$SB/.config/ghostty" ] || [ -e "$T/adapters/ghostty" ] && bad "macOS-only files deployed on Linux" || ok
[ -x "$SB/scripts/tmux_sessions" ] && [ -x "$SB/scripts/tmux-switcher" ] && ok || bad "tmux scripts not deployed executable"

. "$T/lib/registry.sh"
reg() { registry_dump_section "$1" "$2" "$3" | awk -F'\t' -v k="$4" '$1==k {print $2}'; }

step "2. login shell, fresh host (nothing generated yet)"
out=$(zsh -lc 'command -v theme-switch theme-generate' 2>&1)
has "$out" "$T/bin/theme-switch" "theme-switch on PATH"
has "$out" "$T/bin/theme-generate" "theme-generate on PATH"
eq "$(zsh -lc 'echo ${FZF_DEFAULT_OPTS_FILE-unset}' 2>&1 | tail -1)" unset "FZF_DEFAULT_OPTS_FILE must stay unset until active.opts exists"
out=$(zsh -lc 'print a | fzf --filter a' 2>&1); eq "$out" a "fzf works without an opts file"

step "3. tmux starts on a fresh host: theme generated and loaded by tmux-layout.conf"
[ -e "$T/generated" ] && bad "generated/ must not exist yet" || ok
tmux -f "$SB/.tmux.conf" new-session -d -s t -x 200 -y 50 >"$W/tmux-start.log" 2>&1 </dev/null
tmux has-session -t t 2>/dev/null && ok || bad "tmux did not start: $(cat "$W/tmux-start.log")"
[ -s "$T/generated/tmux/tokyonight-night.conf" ] && ok || bad "load_theme.sh did not generate the default theme"
eq "$(tmux show -gv @DEFAULT_BG 2>&1)" "$(reg tokyonight-night dark tmux default_bg)" "@DEFAULT_BG after start-up"
out=$(tmux list-keys -T root 2>&1)
has "$out" 'M->.*theme-switch -q' "Alt-> binding"
has "$out" 'M-<.*theme-switch -q --mode' "Alt-< binding"
has "$(tmux show -gv status-right 2>&1)" 'lib/tmux/session_context.sh' "status-right helper path"
[ -f "$T/lib/tmux/session_context.sh" ] && ok || bad "status-right helper missing"
out=$(tmux source-file "$SB/.tmux.conf" 2>&1)
printf '%s' "$out" | grep -qi 'themes\|layout\|theme' && bad "tmux.conf reload reports theme errors: $out" || ok
[ -z "$out" ] || echo "   (tmux said, unrelated to themes: $out)"

step "4. switch with a running tmux, then reload tmux.conf keeps the choice"
"$T/bin/theme-switch" gruvbox >/dev/null 2>&1; eq $? 0 "theme-switch gruvbox"
eq "$(tmux show -gv @DEFAULT_BG)" "$(reg gruvbox dark tmux default_bg)" "@DEFAULT_BG after switch"
tmux source-file "$SB/.tmux.conf" >/dev/null 2>&1
eq "$(tmux show -gv @DEFAULT_BG)" "$(reg gruvbox dark tmux default_bg)" "@DEFAULT_BG after tmux.conf reload"
"$T/bin/theme-switch" -q --mode light >"$W/out" 2>&1; eq $? 0 "theme-switch -q --mode light"
[ ! -s "$W/out" ] && ok || bad "theme-switch -q --mode must print nothing: $(cat "$W/out")"
eq "$(cat "$SB/.bg_mode")" light "bg_mode after --mode light"
"$T/bin/theme-switch" -q --mode purple >/dev/null 2>&1; eq $? 2 "theme-switch --mode purple"
"$T/bin/theme-switch" -q --mode dark >/dev/null 2>&1; eq "$(cat "$SB/.bg_mode")" dark "--mode dark"
tmux kill-server >/dev/null 2>&1

step "5. login shell after the first generate: fzf picks up the live opts file"
OPTS="$T/generated/fzf/active.opts"
eq "$(zsh -lc 'echo $FZF_DEFAULT_OPTS_FILE' 2>&1 | tail -1)" "$OPTS" "FZF_DEFAULT_OPTS_FILE"
fzf_run() { zsh -lc 'source ~/.config/fzf/config.zsh 2>/dev/null; print a | fzf --filter a' 2>&1; }
eq "$(fzf_run)" a "fzf (wrapper + FZF_DEFAULT_OPTS + opts file) runs"
before=$(cat "$OPTS")
"$T/bin/theme-switch" nordfox >/dev/null 2>&1
[ "$before" != "$(cat "$OPTS")" ] && ok || bad "active.opts did not change on switch"
eq "$(fzf_run)" a "fzf runs after a theme switch (no shell restart)"
grep -q "color=bg:$(reg nordfox dark fzf bg)" "$OPTS" && ok || bad "active.opts does not hold the nordfox background"
out=$(zsh -lc 'source ~/.config/fzf/config.zsh 2>/dev/null; typeset -f fzf; echo "$FZF_DEFAULT_OPTS"' 2>&1)
lacks "$out" 'THEME\|resolve-theme\|_fzf_theme' "fzf wrapper / FZF_DEFAULT_OPTS"
has "$out" "color='header:" "header colour still forced after the theme colours"
# what fzf really draws: run it in a pseudo terminal and read the colours it emits.
# The shell has no FZF_DEFAULT_OPTS_FILE here on purpose: the wrapper must supply it.
if command -v python3 >/dev/null 2>&1; then
  fzf_drawn() { env -u FZF_DEFAULT_OPTS_FILE python3 "$ROOT/dev/pty-colors.py" --secs 3 -- \
                  zsh -c 'source ~/.config/fzf/config.zsh 2>/dev/null; print -l alpha beta | fzf'; }
  "$T/bin/theme-switch" gruvbox >/dev/null 2>&1
  gb=$(reg gruvbox dark fzf bg | tr 'A-F' 'a-f'); nb=$(reg nordfox dark fzf bg | tr 'A-F' 'a-f')
  out=$(fzf_drawn)
  has "$out" "$gb" "fzf draws the gruvbox background"
  lacks "$out" "$nb" "fzf must not draw the nordfox background yet"
  "$T/bin/theme-switch" nordfox >/dev/null 2>&1
  out=$(fzf_drawn)
  has "$out" "$nb" "fzf draws the nordfox background right after theme-switch"
  lacks "$out" "$gb" "fzf no longer draws gruvbox"
else
  echo "   (python3 not available: fzf drawing check skipped)"
fi
# robustness: a missing opts file must not break the shell helpers (guard lives in .zprofile)
mv "$OPTS" "$OPTS.bak"
eq "$(zsh -lc 'echo ${FZF_DEFAULT_OPTS_FILE-unset}' 2>&1 | tail -1)" unset "guard when the opts file is gone"
mv "$OPTS.bak" "$OPTS"
"$T/bin/theme-switch" gruvbox >/dev/null 2>&1

step "6. tmux session scripts use generated/fzf/active.sh"
for s in tmux_sessions tmux-switcher; do
  f="$SB/scripts/$s"
  grep -q 'generated/fzf/active.sh' "$f" && ok || bad "$s does not use active.sh"
  grep -q 'resolve-theme\|selected_theme' "$f" && bad "$s still uses resolve-theme / \$THEME" || ok
  bash -n "$f" 2>/dev/null && ok || bad "$s: bash syntax"
done
# the block both scripts use: sourcing active.sh yields theme_opts with real colour options
out=$(zsh -c 'theme_opts=(); set -o noglob; source "$HOME/.config/themes/generated/fzf/active.sh"; set +o noglob; print -l -- "${theme_opts[@]}"' 2>&1)
has "$out" "--color=bg:$(reg gruvbox dark fzf bg)" "theme_opts from active.sh (zsh)"
eq "$(printf '%s\n' "$out" | grep -c '^--color=')" 14 "number of colour options"

step "7. zsh widget and config syntax"
zsh -n "$SB/custom_config.zsh" && zsh -n "$SB/.config/fzf/config.zsh" && zsh -n "$SB/.zprofile" && ok || bad "zsh syntax error"
grep -q 'theme-switch </dev/tty' "$SB/custom_config.zsh" && ok || bad "widget does not call theme-switch"
grep -q 'theme-list' "$SB/custom_config.zsh" && bad "widget still calls theme-list" || ok

step "8. delta: plain 'delta' (lazygit pager) follows the active theme without --dark/--light"
cat > "$W/sample.diff" <<'DIFF'
diff --git a/x.lua b/x.lua
index 1111111..2222222 100644
--- a/x.lua
+++ b/x.lua
@@ -1,4 +1,4 @@
 local M = {}
-local answer = "old"
+local answer = "new" -- comment
 function M.f(a) return a + 1 end
 return M
DIFF
export GIT_CONFIG_GLOBAL="$SB/.gitconfig" GIT_CONFIG_NOSYSTEM=1
for m in dark light; do
  "$T/bin/theme-switch" "$m" >/dev/null 2>&1
  plain=$(delta < "$W/sample.diff" 2>&1); forced=$(delta "--$m" < "$W/sample.diff" 2>&1)
  [ -n "$plain" ] && [ "$plain" = "$forced" ] && ok || bad "plain delta differs from 'delta --$m'"
  git config --get delta.features | grep -q . && ok || bad "delta.features unset ($m)"
done
# theme really changes the output
"$T/bin/theme-switch" gruvbox >/dev/null 2>&1; a=$(delta < "$W/sample.diff" 2>&1)
"$T/bin/theme-switch" nordfox >/dev/null 2>&1; b=$(delta < "$W/sample.diff" 2>&1)
[ "$a" != "$b" ] && ok || bad "delta output identical for gruvbox and nordfox"
"$T/bin/theme-switch" gruvbox >/dev/null 2>&1
unset GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM

step "9. lazygit config"
LGC="$SB/.config/lazygit/config.yml"
grep -q 'pager: delta --paging=never' "$LGC" && ok || bad "lazygit pager is not plain delta"
grep -q 'delta-pager' "$LGC" && bad "lazygit still references delta-pager" || ok
grep -q "LG_CONFIG_FILE=.*lazygit-active-theme.yml" "$SB/.zprofile" && ok || bad ".zprofile lost the LG_CONFIG_FILE overlay"
[ -s "$T/generated/lazygit/lazygit-active-theme.yml" ] && ok || bad "lazygit overlay not generated"
if command -v lazygit >/dev/null 2>&1 && command -v script >/dev/null 2>&1; then
  repo="$W/repo"; mkdir -p "$repo"; git -C "$repo" init -q . 2>/dev/null; echo hi > "$repo/f"
  out=$( ( sleep 3; printf q ) | LG_CONFIG_FILE="$LGC,$T/generated/lazygit/lazygit-active-theme.yml" TERM=xterm-256color \
         run_limited 20 script -qec "lazygit -p $repo" /dev/null 2>&1 | tr -d '\r' | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' )
  printf '%s' "$out" | grep -qi 'error\|panic\|unmarshal\|invalid\|failed\|yaml' && bad "lazygit rejected the config: $(printf '%s' "$out" | grep -i 'error\|panic\|unmarshal\|invalid\|failed\|yaml' | head -3)" || ok
else
  echo "   (lazygit or script not available: startup check skipped)"
fi

step "10. no leftovers of the removed pieces in the source"
hits=$(cd "$SRC" && grep -rInE 'resolve-theme|theme-list|delta-pager|theme-notify|theme-monitor|get-theme|tmux-theme-switcher' . \
       --exclude=.chezmoiignore --exclude=.chezmoiremove --exclude-dir=.git 2>/dev/null | grep -v '^./dot_config/themes/dev/')
[ -z "$hits" ] && ok || bad "references to removed scripts:
$hits"

HOME="$REAL_HOME"
summary
