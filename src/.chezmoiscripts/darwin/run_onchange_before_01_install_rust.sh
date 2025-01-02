#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Constants
readonly RUST_INSTALL_URL="https://sh.rustup.rs"
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color
readonly SUCCESS_SIGN='✔ '
readonly ERROR_SIGN='✖ '

# Check OS (macOS only).
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}${ERROR_SIGN}This script is for macOS only.${NC}" >&2
    exit 1
fi

# Function to install Rust
install_rust() {
    curl -sSf "$RUST_INSTALL_URL" | sh -s -- -yq --profile default
    source "$HOME/.cargo/env"
}

# Check if Rust is installed.
if command -v rustup &> /dev/null; then
    echo -e "${GREEN}${SUCCESS_SIGN}Rust is already installed.${NC}"
else
    install_rust
fi
