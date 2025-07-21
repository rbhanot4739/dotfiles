#!/bin/zsh

theme_opts=(
    --color=bg:${BACKGROUND}              # Main background
    --color=bg+:${COMMENT}                # Selected item background
    --color=fg:${FOREGROUND}              # Default text
    --color=hl:${BRIGHT_YELLOW}           # Search highlights
    --color=hl+:${BRIGHT_YELLOW}          # Highlights on selected
    --color=border:${MILK}                # Window borders
    --color=gutter:${BACKGROUND}          # Left margin
    --color=header:${ORANGE}              # Header text
    --color=info:${ORANGE}                # Status info
    --color=label:${SOFT_YELLOW}          # Labels
    --color=marker:${ERROR_RED}           # Multi-select markers
    --color=pointer:bold:${BRIGHT_YELLOW} # Selection arrow
    --color=prompt:${LIGHT_BLUE}          # Input prompt
    --color=query:${FOREGROUND}:regular   # Search input text
    --color=scrollbar:${MILK}             # Scrollbar
    --color=separator:${BACKGROUND}        # Separators
    --color=spinner:${BRIGHT_YELLOW}      # Loading spinner
)
