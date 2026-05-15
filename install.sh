```bash
#!/usr/bin/env bash
# Fresh macOS bootstrap
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/rbhanot4739/dotfiles/main/install.sh)

set -Eeuo pipefail

# Debugging (optional)
# set -x

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         dotfiles bootstrap — fresh macOS setup      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# ── Ensure interactive terminal ──────────────────────────────────────────────
if [[ ! -t 1 ]]; then
  echo "Error: this script requires an interactive terminal."
  exit 1
fi

TTY="/dev/tty"

# ── 1. GitHub username ───────────────────────────────────────────────────────
if [[ -z "${GITHUB_USERNAME:-}" ]]; then
  printf "GitHub username: "
  read -r GITHUB_USERNAME < "${TTY}"
fi

export GITHUB_USERNAME

echo "→ Using GitHub username: ${GITHUB_USERNAME}"

# ── 2. Request sudo upfront ──────────────────────────────────────────────────
echo ""
echo "→ Requesting sudo access..."

sudo -v < "${TTY}"

# Keep sudo alive
(
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done
) 2>/dev/null &

SUDO_KEEPALIVE_PID=$!

cleanup() {
  kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true
}

trap cleanup EXIT

# ── 3. Install Xcode Command Line Tools ──────────────────────────────────────
if ! xcode-select -p >/dev/null 2>&1; then
  echo ""
  echo "→ Installing Xcode Command Line Tools..."
  xcode-select --install || true

  echo "→ Waiting for Command Line Tools installation..."

  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
fi

# ── 4. Install Homebrew ──────────────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
  echo ""
  echo "→ Installing Homebrew..."

  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ── 5. Configure brew shellenv ───────────────────────────────────────────────
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ── 6. Install GitHub CLI ────────────────────────────────────────────────────
if ! command -v gh >/dev/null 2>&1; then
  echo ""
  echo "→ Installing GitHub CLI..."
  brew install gh
fi

# ── 7. Authenticate GitHub ───────────────────────────────────────────────────
echo ""

if ! gh auth status >/dev/null 2>&1; then
  echo "→ GitHub authentication required."
  echo "→ A browser window may open."

  gh auth login --web --git-protocol ssh
else
  echo "→ Already authenticated with GitHub."
fi

# ── 8. SSH key setup ─────────────────────────────────────────────────────────
SSH_KEY="${HOME}/.ssh/id_ed25519"

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

if [[ ! -f "${SSH_KEY}" ]]; then
  echo ""
  echo "→ Generating SSH key..."

  ssh-keygen \
    -t ed25519 \
    -C "${GITHUB_USERNAME}@$(hostname -s)" \
    -f "${SSH_KEY}" \
    -N ""

  echo ""
  echo "→ Uploading SSH key to GitHub..."

  gh ssh-key add "${SSH_KEY}.pub" \
    --title "$(hostname -s)"
else
  echo "→ SSH key already exists."
fi

# ── 9. Start ssh-agent ───────────────────────────────────────────────────────
eval "$(ssh-agent -s)" >/dev/null

ssh-add "${SSH_KEY}" >/dev/null 2>&1 || true

# ── 10. Install chezmoi ──────────────────────────────────────────────────────
if ! command -v chezmoi >/dev/null 2>&1; then
  echo ""
  echo "→ Installing chezmoi..."

  brew install chezmoi
fi

# ── 11. Apply dotfiles ───────────────────────────────────────────────────────
echo ""
echo "→ Applying dotfiles..."

chezmoi init --apply \
  "git@github.com:${GITHUB_USERNAME}/dotfiles.git"

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  ✅ Bootstrap complete!                             ║"
echo "║  Open a new terminal to load your environment.      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
```
