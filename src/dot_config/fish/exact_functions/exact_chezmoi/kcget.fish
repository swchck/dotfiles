# Description: Get secret from macOS Keychain
function kcget
    set -l service (read -p "Enter service name: ")
    set -l username (read -p "Enter username: ")
    set -l value (chezmoi secret keyring get --service=$service --user=$username)

    echo "Secret value: $value"
end
