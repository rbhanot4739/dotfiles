# fzf popup used by theme-switch (theme list and --mode). Source this file; do not execute it.
# Needs lib/state.sh (for THEMES_GENERATED). Portable to bash 3.2.
#
#   picker_run <prompt> <header>
#     stdin : rows of "key<TAB>display text" (only the display text is shown)
#     stdout: the key of the chosen row
#     status: 0 chosen, 1 cancelled, 2 fzf missing
#
# Uses fzf's own tmux popup when inside tmux (fzf >= 0.53), otherwise an inline list.
# Colours come from generated/fzf/active.opts (written by theme-switch) when present.

picker_run() {
  local prompt="$1" header="$2" line l
  local -a o

  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is required for the interactive picker (use 'theme-switch --list' / 'theme-switch <name>')" >&2
    return 2
  fi

  o=(--ansi --cycle --layout=reverse --border=rounded --padding=1,2 --no-multi
     --delimiter=$'\t' --with-nth=2 --tiebreak=index
     --prompt="$prompt" --header="$header")

  if [ -n "${TMUX:-}" ] && fzf --help 2>&1 | grep -q -- '--tmux'; then
    o[${#o[@]}]="--tmux=center,60%,50%"
  else
    o[${#o[@]}]="--height=50%"
    o[${#o[@]}]="--margin=5%,15%"
  fi

  if [ -r "$THEMES_GENERATED/fzf/active.opts" ]; then
    while IFS= read -r l; do
      [ -n "$l" ] && o[${#o[@]}]="$l"
    done < "$THEMES_GENERATED/fzf/active.opts"
  fi

  line=$(fzf "${o[@]}") || return 1
  [ -n "$line" ] || return 1
  printf '%s\n' "${line%%$'\t'*}"
}
