# Description: Edit and re-encrypt secrets.toml.age in dotfiles repo
function secrets-sync
    set -l recipient "age1dwv7kax4macfa4jykfp6ksatgeucggfn2rfjjd7305993fn3uy6q58tqr0"
    set -l key_file "$HOME/.config/chezmoi/key.txt"
    set -l source "$HOME/.repository/personal/dotfiles/src/.chezmoitemplates/secrets.toml.age"

    if not test -f "$key_file"
        echo "Error: age key not found at $key_file"
        return 1
    end

    if not test -f "$source"
        echo "Error: secrets file not found at $source"
        return 1
    end

    # Decrypt current secrets to temp file
    set -l tmpfile (command mktemp /tmp/secrets.XXXXXX.toml)
    age -d -i "$key_file" "$source" > $tmpfile 2>/dev/null

    # Open in editor
    $EDITOR $tmpfile

    # Re-encrypt and save
    age -r $recipient -o $source $tmpfile 2>/dev/null
    command rm $tmpfile

    echo "Secrets updated and encrypted in dotfiles repo"
end
