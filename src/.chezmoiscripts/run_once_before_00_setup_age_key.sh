#!/usr/bin/env bash

# Extract age secret key from macOS Keychain and write to chezmoi key file.
# Runs once on first chezmoi init.

set -euo pipefail

KEY_FILE="${HOME}/.config/chezmoi/key.txt"

if [ -f "$KEY_FILE" ]; then
    exit 0
fi

echo "Setting up age decryption key from Keychain..."

SECRET=$(security find-generic-password -a "chezmoi" -s "age-secret-key" -w 2>/dev/null) || {
    echo "ERROR: age-secret-key not found in Keychain."
    echo "Add it with: security add-generic-password -a chezmoi -s age-secret-key -w '<YOUR_AGE_SECRET_KEY>'"
    exit 1
}

mkdir -p "$(dirname "$KEY_FILE")"
printf "# age secret key (extracted from Keychain)\n%s\n" "$SECRET" > "$KEY_FILE"
chmod 600 "$KEY_FILE"

echo "Age key written to $KEY_FILE"
