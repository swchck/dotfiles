#!/usr/bin/env bash

#################################
#         Pre-configure         #
#################################

# Exit immediately if a command exits with a non-zero status
set -eufo pipefail

# Close System Preferences to prevent overriding settings.
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
echo "Please enter your sudo password. It's required for altering macOS defaults."
sudo -v

# Run Keep-Alive for sudo until the script is finished.
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

#################################
#          General UI           #
#################################

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "k3rnel-pan1c"
sudo scutil --set HostName "k3rnel-pan1c"
sudo scutil --set LocalHostName "k3rnel-pan1c"
