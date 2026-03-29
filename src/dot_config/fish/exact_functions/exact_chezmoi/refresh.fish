# Description: Shortener for chezmoi update.
function refresh
    # Check if 'chezmoi' is installed
    if not type -q chezmoi
        echo "Error: 'chezmoi' is not installed. Please install it first."
        return 1
    end

    chezmoi update
end
