# Description: A wrapper around 'bat' to print the content of a file 
# with syntax highlighting, but without decorations.
function pcat
    # Check if 'bat' is installed
    if not type -q bat
        echo "Error: 'bat' is not installed. Please install it first."
        return 1
    end

    bat --style=plain --color=always $argv
end
