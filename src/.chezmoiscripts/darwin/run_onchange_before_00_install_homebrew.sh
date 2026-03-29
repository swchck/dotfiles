#!/usr/bin/env bash

set -euo pipefail

# ── Xcode Command Line Tools ────────────────────────────────────────

if ! xcode-select --print-path &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install &>/dev/null

    # Wait for installation (GUI process)
    until xcode-select --print-path &>/dev/null; do
        sleep 5
    done
    echo "Xcode Command Line Tools installed."
else
    echo "Xcode Command Line Tools already installed."
fi

# ── Homebrew ─────────────────────────────────────────────────────────

if command -v brew &>/dev/null; then
    echo "Homebrew already installed."
else
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Make available in this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "Homebrew installed."
fi
