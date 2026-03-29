#!/usr/bin/env bash
# Bootstrap dotfiles on a fresh machine.
# Usage: bash <(curl -s https://raw.githubusercontent.com/swchck/dotfiles/master/setup.sh)
#
# This is a thin wrapper around `chezmoi init --apply`.

set -euo pipefail

GITHUB_USER="swchck"

# On macOS, ensure Xcode CLI Tools are available (needed for git/curl)
if [ "$(uname)" = "Darwin" ] && ! xcode-select --print-path &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install &>/dev/null
    until xcode-select --print-path &>/dev/null; do sleep 5; done
fi

# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$GITHUB_USER"
