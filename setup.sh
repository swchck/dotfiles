#!/usr/bin/env bash

# xcode_select_setup function.
# This function installs XCode Command Line Tools and waits until installation has finished.
function xcode_select_setup() {
  # Install XCode Command Line Tools.
  xcode-select --install > /dev/null 2>&1

  # Wait until XCode Command Line Tools installation has finished.
  # This is necessary because the XCode CLI installation is a GUI process.
  until xcode-select --print-path > /dev/null 2>&1; do
    sleep 5;
  done
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
  
  # Call Chezmoi One-Shot Install.
  if [ ! "$(command -v chezmoi)" ]; then
    if [ "$(command -v curl)" ]; then
      sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot "$1"
    elif [ "$(command -v wget)" ]; then
      sh -c "$(wget -qO- get.chezmoi.io)" -- init --one-shot "$1"
    else
      echo "To install chezmoi, you must have curl or wget installed." >&2
      exit 1
    fi
  else
    # If Chezmoi is already installed, prompt for confirmation to run Chezmoi One-Shot Install.
    read -p "Chezmoi is already installed. Do you want to run Chezmoi One-Shot Install? (y/n): " CONFIRM
    if [ "$CONFIRM" = "y" ]; then
      chezmoi init --one-shot "$1"
    else
      echo "Chezmoi One-Shot Install was not run." >&2
    fi
  fi
}

# Check OS (macOS only).
# TODO: Add support for Linux.
if [ "$(uname)" != "Darwin" ]; then
  echo "This script is for macOS only." >&2
  exit 1
fi

# Prompt for GitHub username.
read -p "Enter GitHub username: " GITHUB_USER

# Call macOS_setup function with GitHub username as argument.
macOS_setup "$GITHUB_USER"