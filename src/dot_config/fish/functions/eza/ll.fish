# Description: Use eza to list files and directories in a detailed list format

# Function: ll
# This function uses the 'eza' command to display files and directories
# in a detailed list format. It includes options to show hidden files,
# group directories first, display Git status, and include a header.
function ll
    # Check if 'eza' is installed
    if not type -q eza
        echo "Error: 'eza' is not installed. Please install it first."
        return 1
    end

    # Execute 'eza' with the specified options
    eza -l --all --group-directories-first --git --header
end
