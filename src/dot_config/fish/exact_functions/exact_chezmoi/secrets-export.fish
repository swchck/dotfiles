# Description: Export chezmoi Keychain secrets to age-encrypted file
function secrets-export
    set -l secrets_file (command mktemp)
    set -l output "$HOME/.config/chezmoi/secrets.age"
    set -l recipient "age1dwv7kax4macfa4jykfp6ksatgeucggfn2rfjjd7305993fn3uy6q58tqr0"

    for service in age-secret-key gitlab-token ghorg-gitlab-token ghorg-github-token code-stats-token vpn-primary-password
        set -l value (security find-generic-password -a "chezmoi" -s "$service" -w 2>/dev/null)
        if test -n "$value"
            echo "$service=$value" >> $secrets_file
        end
    end

    age -r $recipient -o $output $secrets_file
    command rm $secrets_file

    echo "Secrets exported to $output"
    echo "Copy to chezmoi source:"
    echo "  cp $output ~/.repository/personal/dotfiles/src/dot_config/chezmoi/secrets.age"
end
