#!/usr/bin/env bash
# macOS bootstrap — idempotent + shell agnostic
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/rbhanot4739/dotfiles/main/install.sh)
#
# Safe to re-run anytime from:
#   - bash
#   - zsh
#   - sh (as long as bash exists for execution)
#
# Guarantees:
#   - no duplicate shell config entries
#   - no duplicate SSH uploads
#   - no repeated installs
#   - safe chezmoi re-apply
#   - works across Intel + Apple Silicon

set -Eeuo pipefail

###############################################################################
# UI
###############################################################################

bold="$(tput bold 2>/dev/null || true)"
reset="$(tput sgr0 2>/dev/null || true)"

info()  { printf "\n${bold}→ %s${reset}\n" "$*"; }
ok()    { printf "✓ %s\n" "$*"; }
warn()  { printf "⚠ %s\n" "$*"; }
error() { printf "✗ %s\n" "$*" >&2; }

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         dotfiles bootstrap — fresh macOS setup      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

###############################################################################
# REQUIRE INTERACTIVE TERMINAL
###############################################################################

if [[ ! -t 0 || ! -t 1 ]]; then
  error "This script requires an interactive terminal."
  exit 1
fi

TTY="/dev/tty"

###############################################################################
# HELPERS
###############################################################################

append_if_missing() {
  local line="$1"
  local file="$2"

  mkdir -p "$(dirname "$file")"
  touch "$file"

  grep -Fqs "$line" "$file" || printf '\n%s\n' "$line" >> "$file"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

brew_bin() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    echo "/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    echo "/usr/local/bin/brew"
  else
    return 1
  fi
}

###############################################################################
# GITHUB USERNAME
###############################################################################

if [[ -z "${GITHUB_USERNAME:-}" ]]; then
  printf "GitHub username: "
  read -r GITHUB_USERNAME < "${TTY}"
fi

export GITHUB_USERNAME

ok "Using GitHub username: ${GITHUB_USERNAME}"

###############################################################################
# SUDO
###############################################################################

info "Requesting sudo access..."

sudo -v < "${TTY}"

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

###############################################################################
# XCODE CLT
###############################################################################

if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools..."

  xcode-select --install || true

  info "Waiting for Xcode Command Line Tools installation..."

  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done

  ok "Xcode Command Line Tools installed."
else
  ok "Xcode Command Line Tools already installed."
fi

###############################################################################
# HOMEBREW
###############################################################################

if ! command_exists brew; then
  info "Installing Homebrew..."

  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  ok "Homebrew installed."
else
  ok "Homebrew already installed."
fi

BREW_BIN="$(brew_bin)"

if [[ -z "${BREW_BIN:-}" ]]; then
  error "brew not found after installation."
  exit 1
fi

eval "$("${BREW_BIN}" shellenv)"

###############################################################################
# PERSIST BREW SHELLENV (IDEMPOTENT)
###############################################################################

BREW_SHELLENV_LINE="eval \"\$(${BREW_BIN} shellenv)\""

append_if_missing "${BREW_SHELLENV_LINE}" "${HOME}/.zprofile"

# bash users
append_if_missing "${BREW_SHELLENV_LINE}" "${HOME}/.bash_profile"

###############################################################################
# HOMEBREW PACKAGES
###############################################################################

brew_install_if_missing() {
  local formula="$1"

  if brew list --formula | grep -Fxq "$formula"; then
    ok "${formula} already installed."
  else
    info "Installing ${formula}..."
    brew install "${formula}"
  fi
}

brew_install_if_missing gh
brew_install_if_missing chezmoi

###############################################################################
# GITHUB AUTH
###############################################################################

if gh auth status >/dev/null 2>&1; then
  ok "Already authenticated with GitHub."
else
  info "GitHub authentication required."
  info "A browser window may open."

  gh auth login --web --git-protocol ssh
fi

###############################################################################
# SSH SETUP
###############################################################################

SSH_DIR="${HOME}/.ssh"
SSH_KEY="${SSH_DIR}/id_ed25519"
SSH_PUB="${SSH_KEY}.pub"
HOSTNAME_SHORT="$(hostname -s)"

mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

if [[ ! -f "${SSH_KEY}" ]]; then
  info "Generating SSH key..."

  ssh-keygen \
    -t ed25519 \
    -C "${GITHUB_USERNAME}@${HOSTNAME_SHORT}" \
    -f "${SSH_KEY}" \
    -N ""

  ok "SSH key generated."
else
  ok "SSH key already exists."
fi

###############################################################################
# SSH AGENT
###############################################################################

if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
  eval "$(ssh-agent -s)" >/dev/null
fi

ssh-add --apple-use-keychain "${SSH_KEY}" >/dev/null 2>&1 || true

###############################################################################
# SSH CONFIG (IDEMPOTENT)
###############################################################################

SSH_CONFIG="${SSH_DIR}/config"

append_if_missing "Host github.com" "${SSH_CONFIG}"
append_if_missing "  AddKeysToAgent yes" "${SSH_CONFIG}"
append_if_missing "  UseKeychain yes" "${SSH_CONFIG}"
append_if_missing "  IdentityFile ~/.ssh/id_ed25519" "${SSH_CONFIG}"

chmod 600 "${SSH_CONFIG}"

###############################################################################
# ADD SSH KEY TO GITHUB (IDEMPOTENT)
###############################################################################

PUBKEY_CONTENT="$(cat "${SSH_PUB}")"

if gh ssh-key list | grep -Fq "${PUBKEY_CONTENT}"; then
  ok "SSH key already uploaded to GitHub."
else
  info "Uploading SSH key to GitHub..."

  gh ssh-key add "${SSH_PUB}" \
    --title "${HOSTNAME_SHORT}"

  ok "SSH key uploaded."
fi

###############################################################################
# VERIFY SSH ACCESS
###############################################################################

info "Verifying GitHub SSH access..."

ssh -o StrictHostKeyChecking=accept-new \
    -T git@github.com || true

###############################################################################
# CHEZMOI
###############################################################################

DOTFILES_REPO="git@github.com:${GITHUB_USERNAME}/dotfiles.git"

if [[ -d "${HOME}/.local/share/chezmoi/.git" ]]; then
  info "Updating existing chezmoi repo..."

  chezmoi update
else
  info "Initializing chezmoi..."

  chezmoi init --apply "${DOTFILES_REPO}"
fi

###############################################################################
# DONE
###############################################################################

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  ✅ Bootstrap complete!                             ║"
echo "║  Re-run this script anytime safely.                 ║"
echo "║  Open a new terminal to reload your environment.    ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
