# Theme System

Unified theme manager for Ghostty, WezTerm, tmux, Neovim, fzf, delta, lazygit.

## How It Works

**State files** (source of truth):
- `~/.bg_mode` — `dark` or `light`
- `~/.theme_dark` / `~/.theme_light` — active theme name

**Flow:**
```
registry/*.yaml  ->  theme-generate  ->  generated/  ->  theme-switch  ->  all tools
```

Each `registry/*.yaml` holds color data for every tool. `theme-generate` compiles
them into per-tool config snippets in `generated/`. `theme-switch` applies the
current theme live (OSC escape sequences for terminals, tmux source-file, nvr for
Neovim, sd/yq for delta/lazygit).

Auto dark/light switching is handled by a LaunchAgent (`com.rbhanot.theme-monitor`)
that watches macOS appearance via `bin/theme-notify` (Swift, KVO on
`NSApp.effectiveAppearance`) and calls `theme-switch` on change.

## Shell Hookup

```zsh
# .zprofile — puts theme-switch, theme-list, etc. on PATH
[[ -d "$HOME/.config/themes/bin" ]] && export PATH="$HOME/.config/themes/bin:$PATH"

# fzf_config.zsh — fzf() wrapper sources lib/resolve-theme.sh and injects theme colors
# custom_config.zsh — ZLE widget bound to Alt+> calls theme-list
```

Nothing runs at shell startup. The fzf wrapper applies colors lazily per invocation.

## Rebuild from Scratch

```bash
# 1. Compile the Swift notifier
swiftc -framework Cocoa bin/theme-notify.swift -o bin/theme-notify
chmod +x bin/theme-notify

# 2. Regenerate all tool configs
theme-generate

# 3. Load the LaunchAgent
launchctl load ~/Library/LaunchAgents/com.rbhanot.theme-monitor.plist

# 4. Set initial state and apply
echo "dark" > ~/.bg_mode && echo "tokyonight-night" > ~/.theme_dark
theme-switch
```

Dependencies: `yq`, `sd`, `nvr` (neovim-remote), Xcode CLT (for swiftc).

## Adding a Theme

```bash
theme-import          # interactive deduped picker across tinted/gogh/iterm2/wezterm
theme-import [name]   # import a specific theme name (source auto-fallback)
theme-import --refresh
theme-import --no-fzf --yes --source auto "<name>"

# or manually: copy an existing registry/*.yaml, edit colors, then:
theme-generate && theme-list
```

Notes:
- Remote source indexes are cached in `~/.cache/theme-import` (default TTL: 1 day).
- Use `--refresh` to force catalog refresh immediately.

## Removing a Theme

```bash
theme-remove <name>
```

## chezmoi

Exclude from tracking:
```
dot_config/themes/generated
dot_config/themes/bin/theme-notify
```
