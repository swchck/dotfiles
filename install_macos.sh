#!/bin/sh

# On MacOS should be run with sudo privileges

set -e

GITHUB_USER=swchck

if [ ! "$(command -v chezmoi)" ]; then
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot "$GITHUB_USER"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- get.chezmoi.io)" -- init --one-shot "$GITHUB_USER"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
fi