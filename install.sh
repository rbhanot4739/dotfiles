#!/usr/bin/env bash
# Bootstrap script for a fresh macOS install.
# Usage (recommended — works with curl | bash):
#   curl -fsLS https://raw.githubusercontent.com/rbhanot4739/dotfiles/main/install.sh | bash
# Or run directly:
#   bash install.sh
set -euo pipefail

# ── Restore TTY so interactive prompts work when piped via curl | bash ────────
exec < /dev/tty

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         dotfiles bootstrap — fresh macOS setup       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# ── 1. GITHUB_USERNAME ────────────────────────────────────────────────────────
if [[ -z "${GITHUB_USERNAME:-}" ]]; then
  printf "GitHub username: "
  read -r GITHUB_USERNAME
fi
export GITHUB_USERNAME
echo "→ Using GitHub username: ${GITHUB_USERNAME}"

# ── 2. Pre-cache sudo + keepalive ─────────────────────────────────────────────
echo ""
echo "→ Requesting sudo access (required once for Homebrew install)..."
sudo -v
# Renew sudo timestamp every 60 s so it doesn't expire mid-install
( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true' EXIT

# ── 3. Install Homebrew ───────────────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
  echo ""
  echo "→ Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH for the rest of this script
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── 4. Install gh CLI ─────────────────────────────────────────────────────────
if ! command -v gh >/dev/null 2>&1; then
  echo ""
  echo "→ Installing GitHub CLI (gh)..."
  brew install gh
fi

# ── 5. GitHub authentication ──────────────────────────────────────────────────
echo ""
if ! gh auth status >/dev/null 2>&1; then
  echo "→ Authenticating with GitHub (browser will open)..."
  gh auth login --web --git-protocol ssh
else
  echo "→ Already authenticated with GitHub."
fi

# ── 6. SSH key setup ──────────────────────────────────────────────────────────
SSH_KEY="${HOME}/.ssh/id_ed25519"
mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

if [[ ! -f "${SSH_KEY}" ]]; then
  echo ""
  echo "→ Generating SSH key (~/.ssh/id_ed25519)..."
  ssh-keygen -t ed25519 -C "${GITHUB_USERNAME}@$(hostname -s)" -f "${SSH_KEY}" -N ""
  echo ""
  echo "→ Uploading SSH public key to GitHub..."
  gh ssh-key add "${SSH_KEY}.pub" --title "$(hostname -s)"
else
  echo "→ SSH key already exists at ${SSH_KEY}."
fi

# Ensure the SSH key is in the agent
eval "$(ssh-agent -s)" >/dev/null 2>&1
ssh-add "${SSH_KEY}" 2>/dev/null || true

# ── 7. Install chezmoi + apply dotfiles ───────────────────────────────────────
echo ""
echo "→ Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply \
  "git@github.com:${GITHUB_USERNAME}/dotfiles.git"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  ✅  Bootstrap complete!                             ║"
echo "║  Open a new terminal to get your full environment.  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
