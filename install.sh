#!/bin/sh

set -e

GITHUB_USER=swchck

if [ ! "$(command -v chezmoi)" ]; then
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b $HOME/.local/bin
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
fi

export PATH="$HOME/.local/bin:$PATH"
exec chezmoi init --apply "$GITHUB_USER"