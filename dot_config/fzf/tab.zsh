# vim:set ft=zsh :
# fzf-tab integration and completion overrides.

# Load shared variables/helpers.
source "$HOME/.config/fzf/common.zsh"

zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# Keep popup usable for small candidate sets.
zstyle ':fzf-tab:*' fzf-pad 7
zstyle ':fzf-tab:*' fzf-min-height 15
# fzf-tab's preview init does `local -A ctxt=(${(@0)...})`, which errors with
# "bad set of key/value pairs for associative array" when the candidate metadata
# coming from _approximate/_expand has an odd-numbered split. Restrict every
# command that fzf-tab styles to `_complete` only — the global default in
# .zshrc keeps _approximate everywhere else (typo correction at the prompt).
zstyle ':completion:*:*:(cd|z|__zoxide_z|eza|ls|cat|bat|vim|nvim|v|man|fman|export|unset|expand|ssh|scp|sftp|rsync|-command-|-parameter-|-brace-parameter-):*' completer _complete

# fzf-tab chrome: shared chrome from common.zsh plus `--height=50%` (fixed)
# because fzf cannot re-evaluate height on reload — Alt-i would otherwise leave
# the popup at the pre-reload candidate count.
typeset -ga _FZF_TAB_CHROME=("${_FZF_COMMON_CHROME[@]}" --height=50%)

# Per-context flags. DIR omits FZF_FILE_KEYBIND_EDIT because nvim'ing a
# directory has no useful meaning in `cd <TAB>`.
FZF_TAB_FILE_CTX_FLAGS=("${_FZF_TAB_CHROME[@]}" --header "$FZF_UNIFIED_HEADER_FILE" $FZF_FILE_KEYBIND_EDIT)
FZF_TAB_DIR_CTX_FLAGS=( "${_FZF_TAB_CHROME[@]}" --header "$FZF_UNIFIED_HEADER_DIR")
FZF_TAB_ENV_CTX_FLAGS=( "${_FZF_TAB_CHROME[@]}" --header "$FZF_UNIFIED_HEADER_ENV")
FZF_TAB_MAN_CTX_FLAGS=( "${_FZF_TAB_CHROME[@]}" --header "$FZF_UNIFIED_HEADER_MAN")
FZF_TAB_CTX_DIR=':fzf-tab:complete:(cd|z|__zoxide_z):*'
FZF_TAB_CTX_MIXED=':fzf-tab:complete:(eza|ls):*'
FZF_TAB_CTX_FILE=':fzf-tab:complete:(cat|bat):*'
FZF_TAB_CTX_VIM=':fzf-tab:complete:(vim|nvim|v):*'
FZF_TAB_CTX_ENV=':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*'
FZF_TAB_CTX_MAN=':fzf-tab:complete:(man|fman):*'
FZF_TAB_CTX_SSH=':fzf-tab:complete:ssh:*'

# Default catch-all uses file header.
zstyle ':fzf-tab:*' fzf-flags "${FZF_TAB_FILE_CTX_FLAGS[@]}"

# Each Alt-i binding pairs `reload(...)` with `change-preview(...)` using the
# FZF_TAB_RELOAD_*_PREVIEW templates. Those use `{-1}` instead of `{}`, which
# avoids two transition-state bugs:
#   - fzf-tab's compcap preview init errors with "bad set of key/value pairs"
#     when reload's fd-output candidates aren't in compcap.
#   - With `{}`, fzf substitutes the NUL byte between group and display from
#     OLD candidates still on screen during reload, and Go's exec rejects NUL
#     args (`fork/exec /bin/zsh: invalid argument`). `{-1}` returns the last
#     NUL-delimited column instead — clean for both pre- and post-reload.
zstyle "$FZF_TAB_CTX_DIR" fzf-preview "$FZF_UNIFIED_FZF_TAB_DIR_PREVIEW"
zstyle "$FZF_TAB_CTX_DIR" fzf-flags "${FZF_TAB_DIR_CTX_FLAGS[@]}" --preview-window "$FZF_UNIFIED_DIR_PREVIEW_WINDOW" --border-label 'Fuzzy Find Dirs' --ghost "$FZF_GHOST_DIRS"
zstyle "$FZF_TAB_CTX_DIR" fzf-bindings "alt-i:reload($FZF_UNIFIED_HIDDEN_TOGGLE_DIR_CMD)+change-preview($FZF_TAB_RELOAD_DIR_PREVIEW)"

zstyle "$FZF_TAB_CTX_MIXED" fzf-preview "$FZF_UNIFIED_FZF_TAB_FILE_PREVIEW"
zstyle "$FZF_TAB_CTX_MIXED" fzf-flags "${FZF_TAB_FILE_CTX_FLAGS[@]}" --preview-window "$FZF_UNIFIED_PREVIEW_WINDOW" --border-label 'Fuzzy Files/Dirs' --ghost "$FZF_GHOST_MIXED"
zstyle "$FZF_TAB_CTX_MIXED" fzf-bindings "alt-i:reload($FZF_UNIFIED_HIDDEN_TOGGLE_ALL_CMD)+change-preview($FZF_TAB_RELOAD_FILE_PREVIEW)"

zstyle "$FZF_TAB_CTX_FILE" fzf-preview "$FZF_UNIFIED_FZF_TAB_FILE_PREVIEW"
zstyle "$FZF_TAB_CTX_FILE" fzf-flags "${FZF_TAB_FILE_CTX_FLAGS[@]}" --preview-window "$FZF_UNIFIED_PREVIEW_WINDOW" --border-label 'Fuzzy Find Files' --ghost "$FZF_GHOST_FILES"
zstyle "$FZF_TAB_CTX_FILE" fzf-bindings "alt-i:reload($FZF_UNIFIED_HIDDEN_TOGGLE_FILE_CMD)+change-preview($FZF_TAB_RELOAD_FILE_PREVIEW)"

# Editor contexts.
zstyle "$FZF_TAB_CTX_VIM" fzf-preview "$FZF_UNIFIED_FZF_TAB_FILE_PREVIEW"
zstyle "$FZF_TAB_CTX_VIM" fzf-flags "${FZF_TAB_FILE_CTX_FLAGS[@]}" --preview-window "$FZF_UNIFIED_PREVIEW_WINDOW" --border-label 'Fuzzy Find Files' --ghost "$FZF_GHOST_VIM"
zstyle "$FZF_TAB_CTX_VIM" fzf-bindings "alt-i:reload($FZF_UNIFIED_HIDDEN_TOGGLE_FILE_CMD)+change-preview($FZF_TAB_RELOAD_FILE_PREVIEW)"

# Env-var contexts.
zstyle "$FZF_TAB_CTX_ENV" fzf-preview 'echo ${(P)word}'
zstyle "$FZF_TAB_CTX_ENV" fzf-flags "${FZF_TAB_ENV_CTX_FLAGS[@]}" --ghost "$FZF_GHOST_ENV"

# Man/fman contexts.
zstyle "$FZF_TAB_CTX_MAN" fzf-preview 'tldr --color=always $word 2>/dev/null'
zstyle "$FZF_TAB_CTX_MAN" fzf-flags "${FZF_TAB_MAN_CTX_FLAGS[@]}" --ghost "$FZF_GHOST_MAN"

# SSH host contexts.
zstyle "$FZF_TAB_CTX_SSH" fzf-flags "${FZF_TAB_MAN_CTX_FLAGS[@]}" --ghost "$FZF_GHOST_HOSTS"

# Completion overrides:
# - Use positional compadd (`compadd -- "${arr[@]}"`) for fzf-tab compatibility.
# - Force man/export/unset to share the same sanitized candidate sources used by
#   trigger completion, so `<TAB>` and `,<TAB>` stay consistent.
# - Re-apply compdefs in precmd in case deferred plugins remap them.
__fzf_compadd_env_override() {
  local -a env_vars
  env_vars=( ${(f)"$(__fzf_list_env_vars)"} )
  (( ${#env_vars} )) && compadd -- "${env_vars[@]}"
}

__fzf_compadd_man_override() {
  local -a man_pages
  man_pages=( ${(f)"$(__fzf_list_man_pages)"} )
  (( ${#man_pages} )) && compadd -- "${man_pages[@]}"
}

__fzf_apply_completion_overrides() {
  # `man` may be aliased to `fman`.
  compdef __fzf_compadd_man_override man fman
  compdef __fzf_compadd_env_override export unset
}

# Install once, then re-assert compdef mappings per prompt.
__fzf_apply_completion_overrides
typeset -ag precmd_functions
[[ -z ${precmd_functions[(r)__fzf_apply_completion_overrides]} ]] && \
  precmd_functions+=(__fzf_apply_completion_overrides)
