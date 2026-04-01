#!/usr/bin/env bash

# Bootstrap secrets from age-encrypted file or Keychain.
# On first machine: age key must be added to Keychain manually.
# On subsequent machines: age key must be transferred manually (one time),
# then this script imports all other secrets from encrypted_secrets.age.

set -euo pipefail

KEY_FILE="${HOME}/.config/chezmoi/key.txt"
SECRETS_AGE="${HOME}/.config/chezmoi/secrets.age"

# ── Step 1: Setup age key ────────────────────────────────────────────

if [ ! -f "$KEY_FILE" ]; then
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
fi

# ── Step 2: Import secrets from encrypted file ───────────────────────

if [ -f "$SECRETS_AGE" ] && command -v age &>/dev/null; then
    echo "Importing secrets from encrypted file into Keychain..."

    age -d -i "$KEY_FILE" "$SECRETS_AGE" 2>/dev/null | while IFS='=' read -r service value; do
        if [ -n "$service" ] && [ -n "$value" ]; then
            # Skip age-secret-key (already handled above)
            if [ "$service" = "age-secret-key" ]; then
                continue
            fi
            # Add to Keychain (update if exists)
            security add-generic-password -a "chezmoi" -s "$service" -w "$value" -U 2>/dev/null || true
            echo "  Imported: $service"
        fi
    done

    echo "All secrets imported into Keychain."
else
    echo "No encrypted secrets file found or age not installed, skipping import."
fi
