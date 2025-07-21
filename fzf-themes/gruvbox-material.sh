#!/bin/zsh

theme_opts=(
    --color=fg:${FOREGROUND},bg:${BACKGROUND},hl:${BRIGHT_YELLOW}
    --color=fg+:bold:${FOREGROUND},bg+:${COMMENT},hl+:${BRIGHT_YELLOW}
    --color=gutter:${BACKGROUND},info:${ORANGE},separator:${BACKGROUND}
    --color=border:${MILK},label:${SOFT_YELLOW},prompt:${LIGHT_BLUE}
    --color=spinner:${BRIGHT_YELLOW},pointer:bold:${BRIGHT_YELLOW},marker:${ERROR_RED}
    --color=header:${ORANGE},preview-fg:${FOREGROUND},preview-bg:${BACKGROUND}
)
