# Description: Use eza to list files and directories

# Function: l
# This function uses the 'eza' command to display files and directories
# in a detailed list format. It includes options to show hidden files,
# group directories first, and display Git status.
function l
    # Check if 'eza' is installed
    if not type -q eza
        echo "Error: 'eza' is not installed. Please install it first."
        return 1
    end

    # Execute 'eza' with the specified options
    eza -l --all --group-directories-first --git
end
