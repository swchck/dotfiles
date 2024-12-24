#!/usr/bin/env bash

GITHUB_USER="swchck"

# xcode_select_setup function.
# This function installs XCode Command Line Tools and waits until installation has finished.
function xcode_select_setup() {
  # Check if XCode Command Line Tools are already installed.
  if xcode-select --print-path >/dev/null 2>&1; then
    echo "XCode Command Line Tools are already installed."
    return
  fi

  # Install XCode Command Line Tools.
  xcode-select --install >/dev/null 2>&1

  # Wait until XCode Command Line Tools installation has finished.
  # This is necessary because the XCode CLI installation is a GUI process.
  until xcode-select --print-path >/dev/null 2>&1; do
    sleep 5
  done
}

# chezmoi_install function.
# This function installs Chezmoi and calls Chezmoi One-Shot Install.
function chezmoi_install() {
  set -e

  local IS_INSTALLED=0
  local USE_INSTALLED=0

  # Check if Chezmoi is already installed.
  if [ "$(command -v chezmoi)" ]; then
    IS_INSTALLED=1
  fi

  # Prompt for confirmation to install Chezmoi.
  if [ "$IS_INSTALLED" -eq 1 ]; then
    read -pr "Chezmoi is already installed on your system. Do you want to use installed version? (y/n): " CONFIRM
    if [ "$CONFIRM" == "y" ]; then
      USE_INSTALLED=1
    fi
  else
    echo "Chezmoi will be downloaded and installed."

    # Download Chezmoi binary to .local/bin directory.
    echo "Download latest version of Chezmoi from chezmoi.io..."
    if [ "$(command -v curl)" ]; then
      curl -sfL https://get.chezmoi.io/lb | sh
    elif [ "$(command -v wget)" ]; then
      wget -qO- https://get.chezmoi.io/lb | sh
    else
      echo "curl or wget is required to download Chezmoi binary." >&2
      exit 1
    fi
  fi

  # Run Chezmoi One-Shot Install.
  if [ "$USE_INSTALLED" -eq 1 ]; then
    chezmoi apply --one-shot --verbose
  else
    .local/bin/chezmoi init --apply "$GITHUB_USER"
  fi
}

# macOS_setup function.
# This function installs XCode Command Line Tools,
# waits until installation has finished, and calls Chezmoi One-Shot Install.
# Arguments:
#   $1: GitHub username.
function macOS_setup() {
  # Install XCode Command Line Tools.
  xcode_select_setup

  set -e

  # Install and run Chezmoi One-Shot Install.
  chezmoi_install
}

# cleanup function.
# This function removes Chezmoi binary from .local/bin directory.
function cleanup() {
  # Check if Chezmoi binary is in .local/bin directory.
  if [ -f ~/.local/bin/chezmoi ]; then
    # Remove Chezmoi binary.
    echo "Remove downloaded binary from .local/bin directory."
    rm .local/bin/chezmoi
  fi
}

# Register trap on any signal to call cleanup function.
trap cleanup EXIT

# Check OS (macOS only).
# TODO: Add support for Linux.
if [ "$(uname)" != "Darwin" ]; then
  echo "This script is for macOS only." >&2
  exit 1
fi

# Call macOS_setup function with GitHub username as argument.
macOS_setup
