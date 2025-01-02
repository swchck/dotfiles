# Description: Shortener for bat - a cat clone with wings.
function cat
    # Check if 'bat' is installed
    if not type -q bat
        echo "Error: 'bat' is not installed. Please install it first."
        return 1
    end

    bat $argv
end
