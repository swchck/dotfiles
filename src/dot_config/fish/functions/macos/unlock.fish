# Description: Unlock an application by removing the quarantine attribute

# Function: unlock
# This function removes the quarantine attribute from an application
# to allow it to run without security warnings. It checks if the
# specified path is a valid directory and then removes the quarantine
# attribute using the 'xattr' command.
function unlock
    # Get the application path from the arguments
    set applicationPath $argv

    # Check if the specified path is a valid directory
    if not test -d $applicationPath
        echo "Error: $applicationPath is not a valid directory"
        return 1
    end

    # Get the application name from the path
    set applicationName (basename $applicationPath)
    echo "Unlocking $applicationName"

    # Remove the quarantine attribute
    sudo xattr -rd com.apple.quarantine $applicationPath
    echo "Unlocked $applicationName"
end

# Add completion for the unlock function to suggest only directories from /Applications
complete -c unlock -a '(ls -d /Applications/*/)' -d "Application for unlock" -f
