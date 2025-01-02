# Description: Use eza to list files and directories in a tree-like format

# Function: tree
# This function uses the 'eza' command to display files and directories
# in a tree-like format. It includes options to show hidden files,
# display file sizes, and limit the depth of the tree.
function tree
    # Check if 'eza' is installed
    if not type -q eza
        echo "Error: 'eza' is not installed. Please install it first."
        return 1
    end

    # Default options for 'eza'
    set options --tree --level=2

    # Add options to show hidden files and display file sizes
    set options $options --all --long --header --icons

    # Execute 'eza' with the specified options
    eza $options
end
