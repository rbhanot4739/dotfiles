# Resolves current theme state into THEME and BG_MODE.
# Source this from bash or zsh — do not execute. No forks.
#
# Optional: set _RESOLVE_THEME_OVERRIDE before sourcing to force a theme name.

BG_MODE=
[ -r "$HOME/.bg_mode" ] && BG_MODE=$(<"$HOME/.bg_mode")
BG_MODE=${BG_MODE//[[:space:]]/}
: "${BG_MODE:=dark}"

if [ -n "${_RESOLVE_THEME_OVERRIDE:-}" ]; then
  THEME=$_RESOLVE_THEME_OVERRIDE
else
  THEME=
  [ -r "$HOME/.theme_${BG_MODE}" ] && THEME=$(<"$HOME/.theme_${BG_MODE}")
fi
THEME=${THEME//[[:space:]]/}
: "${THEME:=tokyonight-night}"
