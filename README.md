# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Fresh macOS Setup — One Command

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/rbhanot4739/dotfiles/main/install.sh)
```

That's it. The script handles everything from scratch.

---

## What the Bootstrap Script Does

| Step | What happens |
|------|-------------|
| **1. GitHub username** | Prompts if `$GITHUB_USERNAME` isn't already set |
| **2. sudo keepalive** | Caches sudo credentials + renews them in the background so Homebrew's non-interactive installer can use `sudo` without a prompt |
| **3. Homebrew** | Installs Homebrew to `/opt/homebrew` (Apple Silicon) |
| **4. gh CLI** | Installs the GitHub CLI via `brew install gh` |
| **5. GitHub auth** | Runs `gh auth login --web` — opens a browser for OAuth login (your credentials never touch the script) |
| **6. SSH key** | Generates `~/.ssh/id_ed25519` (if missing) and uploads the public key to your GitHub account |
| **7. chezmoi** | Installs chezmoi and runs `chezmoi init --apply git@github.com:<username>/dotfiles.git` |
| **8. Packages** | chezmoi's setup script runs `brew bundle` to install everything in `Brewfile` + `Brewfile.darwin` |
| **9. Configs** | chezmoi deploys all dotfiles to `$HOME` |

---

## Prerequisites

- A Mac (Apple Silicon recommended) with internet access
- A GitHub account

No other pre-steps required — the script handles SSH keys, Homebrew, and everything else.

---

## Subsequent Updates

After the initial setup, update dotfiles at any time with:

```bash
chezmoi update
```

Or to apply local changes:

```bash
chezmoi apply
```
