# Description: Save secret to macOS Keychain
function kcsave
    set -l service (read -p "Enter service name: ")
    set -l username (read -p "Enter username: ")
    set -l value (read -p "Enter secret value: ")

    chezmoi secret keyring set --service=$service --user=$username --value=$value
    echo "Secret saved to Keychain"
end
