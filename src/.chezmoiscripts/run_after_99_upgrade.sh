#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# This script used for performing upgrade of all installed packages, tools, containers, etc.
# This script is executed every time after the chezmoi apply command is run.
# Configuration file stored in: ~/.config/topgrade.toml

# Check if topgrade is installed
# if [ "$(command -v topgrade)" ]; then
#     # TODO: Make it more convenient to run topgrade with chezmoi.
#     # echo "Running topgrade..."
#     # topgrade --disable chezmoi
# else
#     echo "topgrade is not installed."
#     exit 1
# fi