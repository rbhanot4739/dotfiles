#!/bin/bash

# Wrapper script that takes theme as an argument
# Usage: ./switch-theme.sh [theme_name]

THEME_DIR="$HOME/tmux-themes"

# Get theme from argument or environment, default to gruvbox
THEME_NAME=${1:-${THEME:-gruvbox}}

case "$THEME_NAME" in
    *gruvbox*)
        tmux source-file "$THEME_DIR/gruvbox.conf"
        tmux display-message "Loaded Gruvbox theme"
        ;;
    *nightfox*)
        tmux source-file "$THEME_DIR/nightfox.conf"
        tmux display-message "Loaded Nightfox theme"
        ;;
    *dawnfox*)
        tmux source-file "$THEME_DIR/dawnfox.conf"
        tmux display-message "Loaded Dawnfox theme"
        ;;
    *tokyonight*)
        tmux source-file "$THEME_DIR/tokyonight.conf"
        tmux display-message "Loaded Tokyo Night theme"
        ;;
    *)
        tmux source-file "$THEME_DIR/gruvbox.conf"
        tmux display-message "Loaded default theme (gruvbox)"
        ;;
esac

# Set tmux environment variable for other uses
tmux set-environment -g THEME "$THEME_NAME"

