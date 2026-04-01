#!/usr/bin/env bash

# Setup age decryption key (needed before chezmoi can decrypt files).
# Age key is the ONE secret that must be transferred manually.

set -euo pipefail

KEY_FILE="${HOME}/.config/chezmoi/key.txt"

if [ -f "$KEY_FILE" ]; then
    exit 0
fi

echo "Setting up age decryption key..."

# Try Keychain first
SECRET=$(security find-generic-password -a "chezmoi" -s "age-secret-key" -w 2>/dev/null || true)

if [ -z "$SECRET" ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  age secret key not found in Keychain."
    echo ""
    echo "  This is the ONE secret you must transfer manually."
    echo "  On your existing machine, run:"
    echo "    security find-generic-password -a chezmoi -s age-secret-key -w"
    echo ""
    echo "  Then on this machine:"
    echo "    security add-generic-password -a chezmoi -s age-secret-key -w '<KEY>'"
    echo ""
    echo "  Or paste the age secret key now (AGE-SECRET-KEY-...):"
    echo "═══════════════════════════════════════════════════════════"
    read -r SECRET
    if [ -z "$SECRET" ]; then
        echo "No key provided, aborting."
        exit 1
    fi
    # Save to Keychain for future use
    security add-generic-password -a "chezmoi" -s "age-secret-key" -w "$SECRET" -U 2>/dev/null || true
fi

mkdir -p "$(dirname "$KEY_FILE")"
printf "# age secret key\n%s\n" "$SECRET" > "$KEY_FILE"
chmod 600 "$KEY_FILE"
echo "Age key written to $KEY_FILE"
