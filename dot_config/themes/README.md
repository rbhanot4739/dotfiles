# Themes

One theme for tmux, Neovim, fzf, delta and lazygit, switched with one command.
Works on Linux and macOS (bash 3.2 compatible, no `yq`, no daemon). On macOS two
extra pieces are installed for Ghostty and WezTerm (see [macOS only](#macos-only)).

Over SSH the terminal itself (e.g. Windows Terminal) keeps its own colour scheme.
Pick a matching scheme there; this setup themes everything that runs inside it.

## State

| File | Meaning |
|---|---|
| `~/.bg_mode` | `dark` or `light` |
| `~/.theme_dark`, `~/.theme_light` | theme remembered for each mode |

`registry/*.yaml` holds the colours of every theme. `theme-generate` turns the registry
into ready-to-use snippets in `~/.config/themes/generated/`, `theme-switch` applies one.

```
registry/*.yaml --theme-generate--> generated/ --theme-switch--> tmux, fzf, delta, lazygit, nvim
```

## Commands (on `PATH` via `.zprofile`)

```
theme-switch                  fzf popup listing every registry theme ( * active, + other mode )
theme-switch <name>           switch; flips bg_mode if the theme only exists for the other mode
theme-switch dark|light       switch mode, restoring the theme remembered for it
theme-switch --list           plain list (for scripts)
theme-switch --apply          re-apply the current state (after editing the registry, say)
theme-switch --mode           small popup: dark | light (also: --mode dark|light)
theme-generate                rebuild generated/ from the registry (all or nothing)
```

Key bindings: `Alt->` (tmux root binding and zsh widget) opens `theme-switch`;
`Alt-<` (tmux) opens `theme-switch --mode`.

`theme-switch` is quick and idempotent. Missing generated files are rebuilt on the
way, and a stored theme that no longer exists falls back to
`tokyonight-night` / `tokyonight-day` with a warning.

## What gets updated

| Target | How |
|---|---|
| tmux | `source-file generated/tmux/<key>.conf` into a running server (never starts one) |
| fzf | `generated/fzf/active.opts` (read through `FZF_DEFAULT_OPTS_FILE`), `active.sh` for scripts |
| delta | `generated/delta/delta-active.gitconfig` (included by `~/.delta-gitconfig`) |
| lazygit | `generated/lazygit/lazygit-active-theme.yml` (loaded through `LG_CONFIG_FILE`) |
| Neovim | every instance found by `nvr --serverlist` re-runs `Load_colorscheme()` |

`<key>` is `<name>-dark|light` for adaptive themes, plain `<name>` for single-mode ones.

## Hooks

Executables in `hooks/generate.d/` (run by `theme-generate`) and `hooks/apply.d/`
(run by `theme-switch`) extend the core. A hook that fails only prints a warning.
Environment: `THEMES_ROOT`, `THEMES_REGISTRY`, `THEMES_GENERATED`; apply hooks also
get `THEME`, `BG_MODE`, `THEME_KEY`, `THEMES_QUIET`.

## macOS only

Deployed only when `is_mac` (see `.chezmoiignore`): `adapters/{ghostty,wezterm}` and the
`*-mac-*` hooks. They write `~/.config/ghostty/current-colors.conf`, WezTerm schemes
and `~/.wezterm_themes.lua`, and recolour already open Ghostty/WezTerm windows through
escape sequences.

## Checking a switch by eye

```
theme-switch gruvbox            # then, in any shell:
echo $FZF_DEFAULT_OPTS_FILE     # fzf: set in login shells; the fzf() wrapper does not need it
ls | fzf                        # fzf reads the colours on every start (live)
git diff --no-index /etc/hosts /etc/hostname | delta      # delta: live, read on every run
git config --get-regexp '^delta\.(features|dark|light)'   # which delta section is active
lazygit                         # lazygit reads its config only at start: restart a running one
```

Only lazygit needs a restart; tmux and Neovim update immediately, fzf and delta on their next run.

## Adding a theme

Copy a file in `registry/`, edit the colours (name must equal the file name), then:

```
theme-generate && theme-switch <name>
```

## Overrides (mostly for tests)

`THEMES_REGISTRY`, `THEMES_GENERATED`, `THEMES_STATE_DIR` (default `$HOME`),
`THEMES_SKIP_NVIM=1`.

## Checks

`dev/` is never deployed. Run by hand from this directory:

```
bash dev/verify-registry.sh   bash dev/verify-adapters.sh   bash dev/verify-generate.sh
bash dev/verify-switch.sh     bash dev/verify-mac.sh        bash dev/verify-consumers.sh
```

All of them work in a scratch `HOME`; your real state files are never touched.
