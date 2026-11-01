# Theme state: which dark/light mode is active and which theme is picked for each.
# Source this file; do not execute it. Portable to bash 3.2 (macOS /bin/bash).
#
# State files (the source of truth, shared with nvim and the shell):
#   ~/.bg_mode                  "dark" or "light"
#   ~/.theme_dark ~/.theme_light  active theme name for that mode
# Generated output lives in $THEMES_GENERATED (default ~/.config/themes/generated).
#
# Overridable for tests:  THEMES_STATE_DIR (default $HOME), THEMES_GENERATED.
#
# API
#   state_resolve               sets BG_MODE and THEME (+ THEME_FALLBACK=1 and THEME_STORED=<name>
#                               if the stored theme was missing/invalid and a default was used)
#   state_read_theme <mode>     stored theme name for a mode (may be empty)
#   state_set_bg_mode <mode>    atomic write of ~/.bg_mode
#   state_set_theme <mode> <t>  atomic write of ~/.theme_<mode>
#   state_default_theme <mode>  per-mode default (dark: tokyonight-night, light: tokyonight-day)
#   gen_find <subdir> <ext>     path of the generated file for $THEME/$BG_MODE

# shellcheck source=registry.sh
. "$(dirname "${BASH_SOURCE[0]}")/registry.sh"

THEMES_STATE_DIR="${THEMES_STATE_DIR:-$HOME}"
THEMES_GENERATED="${THEMES_GENERATED:-$HOME/.config/themes/generated}"

state_default_theme() {
  case "$1" in
    light) printf '%s\n' tokyonight-day ;;
    *)     printf '%s\n' tokyonight-night ;;
  esac
}

# First line of a file with all whitespace removed; empty if unreadable.
_state_read() {
  local v=""
  if [ -r "$1" ]; then IFS= read -r v < "$1" || true; fi
  printf '%s' "${v//[[:space:]]/}"
}

# Theme names end up in file paths: allow only plain names.
_state_valid_name() {
  case "$1" in
    ""|.*|*[!A-Za-z0-9._-]*) return 1 ;;
  esac
  return 0
}

state_read_bg_mode() {
  local m
  m=$(_state_read "$THEMES_STATE_DIR/.bg_mode")
  case "$m" in dark|light) printf '%s\n' "$m" ;; *) printf '%s\n' dark ;; esac
}

state_read_theme() {
  _state_read "$THEMES_STATE_DIR/.theme_$1"
}

state_resolve() {
  local stored
  THEME_FALLBACK=0
  BG_MODE=$(state_read_bg_mode)
  stored=$(state_read_theme "$BG_MODE")
  THEME_STORED="$stored"
  if _state_valid_name "$stored" && [ -f "$THEMES_REGISTRY/$stored.yaml" ]; then
    THEME="$stored"
  else
    THEME=$(state_default_theme "$BG_MODE")
    THEME_FALLBACK=1
  fi
}

# state_write <file> <value>: write via a temp file in the same directory + rename,
# so readers (nvim, shells, tmux run-shell) never see a half-written file.
state_write() {
  local f="$1" tmp
  tmp=$(mktemp "$f.XXXXXX") || return 1
  if printf '%s\n' "$2" > "$tmp" && chmod 644 "$tmp" && mv -f "$tmp" "$f"; then
    return 0
  fi
  rm -f "$tmp"
  return 1
}

state_set_bg_mode() {
  case "$1" in dark|light) ;; *) echo "Error: mode must be dark or light" >&2; return 1 ;; esac
  state_write "$THEMES_STATE_DIR/.bg_mode" "$1"
}

state_set_theme() {
  case "$1" in dark|light) ;; *) echo "Error: mode must be dark or light" >&2; return 1 ;; esac
  _state_valid_name "$2" || { echo "Error: invalid theme name: $2" >&2; return 1; }
  state_write "$THEMES_STATE_DIR/.theme_$1" "$2"
}

# gen_find <subdir> <ext>: adaptive themes are generated as <name>-<mode>.<ext>,
# single-mode themes as <name>.<ext>. Prints the path for the current THEME/BG_MODE.
gen_find() {
  local d="$THEMES_GENERATED/$1"
  if [ -f "$d/$THEME-$BG_MODE.$2" ]; then
    printf '%s\n' "$d/$THEME-$BG_MODE.$2"
  elif [ -f "$d/$THEME.$2" ]; then
    printf '%s\n' "$d/$THEME.$2"
  else
    return 1
  fi
}
