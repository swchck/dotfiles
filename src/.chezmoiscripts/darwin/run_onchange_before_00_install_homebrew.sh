#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -eufo pipefail

# Check OS (macOS only).
if [ "$(uname)" != "Darwin" ]; then
    echo "This script is for macOS only." >&2
    exit 1
fi

# Check if Homebrew is installed.
if [ "$(command -v brew)" ]; then
    echo "Homebrew is already installed."
else
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
