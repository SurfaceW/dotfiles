#!/usr/bin/env bash
#
# brew.sh — install command-line tools via Homebrew (idempotent)
#
# Usage:
#   bash brew.sh
#
# Re-running is safe: already-installed packages are skipped.
# This script is invoked by install.sh; you can also run it standalone.

set -uo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "✗ Homebrew not found. Install it first or run install.sh."
  exit 1
fi

echo "→ Updating Homebrew…"
brew update

brew_install() {
  local pkg="$1"
  if brew list --formula "$pkg" &>/dev/null; then
    echo "✓ $pkg already installed"
  else
    echo "→ installing $pkg"
    brew install "$pkg"
  fi
}

brew_install_cask() {
  local pkg="$1"
  if brew list --cask "$pkg" &>/dev/null; then
    echo "✓ cask $pkg already installed"
  else
    echo "→ installing cask $pkg"
    brew install --cask "$pkg"
  fi
}

#   -------------------------------
#   Core CLI
#   -------------------------------
brew_install git
brew_install bash
brew_install bash-completion
brew_install zsh
brew_install vim
brew_install wget
brew_install curl
brew_install tree
brew_install coreutils

#   -------------------------------
#   Search & navigate
#   -------------------------------
brew_install ripgrep
brew_install fd
brew_install fzf
brew_install autojump

#   -------------------------------
#   Data
#   -------------------------------
brew_install jq
brew_install yq

#   -------------------------------
#   Languages & runtimes
#   -------------------------------
brew_install node
brew_install nvm
brew_install python@3.13
brew_install pnpm

#   -------------------------------
#   Quality of life
#   -------------------------------
brew_install gh
brew_install tldr
brew_install htop

#   -------------------------------
#   Optional casks (uncomment as needed)
#   -------------------------------
# brew_install_cask iterm2
# brew_install_cask visual-studio-code
# brew_install_cask sourcetree
# brew_install_cask alfred

echo ""
echo "✓ brew.sh complete."
echo "  Run 'brew cleanup' to remove old versions."
