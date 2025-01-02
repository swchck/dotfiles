#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Homebrew installation URL
readonly HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color
readonly SUCCESS_SIGN='✔ '
readonly ERROR_SIGN='✖ '

# Function to install Homebrew
install_homebrew() {
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL $HOMEBREW_INSTALL_URL)"

    # Ensure .zprofile exists
    [ -f "$HOME/.zprofile" ] || touch "$HOME/.zprofile"

    # Check if Homebrew is already in PATH
    if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$HOME/.zprofile"; then
        # Add Homebrew to PATH
        printf 'eval "$(/opt/homebrew/bin/brew shellenv)"\n' >> "$HOME/.zprofile"
    fi

    # Make Homebrew available in the current shell
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Check OS (macOS only).
if [ "$(uname)" != "Darwin" ]; then
    printf "${RED}${ERROR_SIGN}This script is for macOS only.${NC}\n" >&2
    exit 1
fi

# Check if Homebrew is installed.
if command -v brew &>/dev/null; then
    printf "${GREEN}${SUCCESS_SIGN}Homebrew is already installed.${NC}\n"
else
    install_homebrew
fi
