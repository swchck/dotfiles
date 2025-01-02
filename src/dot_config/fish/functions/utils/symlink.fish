# Description: Create a symlink if it does not exist

# Function: symlink
# This function creates a symbolic link from the target to the link name.
# It checks if the link name already exists and provides an error message if it does.
# If the link name does not exist, it creates the symbolic link.
function symlink
    # Check if the link name already exists
    if test -e $argv[1]
        echo "Error: File already exists: $argv[1]"
    else
        # Create the symbolic link
        ln -s $argv[2] $argv[1]
        echo "Symlink created: $argv[1] -> $argv[2]"
    end
end
