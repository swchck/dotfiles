#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -eufo pipefail

# Check OS (macOS only).
if [ "$(uname)" != "Darwin" ]; then
    echo "This script is for macOS only." >&2
    exit 1
fi

# Check if Rust is installed.
if [ "$(command -v rustup)" ]; then
    echo "Rust is already installed."
else
    # Install Rust
    curl https://sh.rustup.rs -sSf | sh -s -- -yq --profile default
    source "$HOME/.cargo/env"
fi
