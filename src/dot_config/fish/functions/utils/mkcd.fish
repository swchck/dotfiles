# Description: Create a directory and cd into it

# Function: mkcd
# This function creates a directory and then changes into it.
# It uses 'mkdir -p' to create the directory, which ensures that
# any missing parent directories are also created.
# After creating the directory, it uses 'cd' to change into it.
function mkcd
    # Check if a directory name was provided
    if test (count $argv) -eq 0
        echo "Error: No directory name provided"
        return 1
    end

    # Create the directory and any necessary parent directories
    mkdir -p $argv[1]

    # Change into the newly created directory
    cd $argv[1]
end