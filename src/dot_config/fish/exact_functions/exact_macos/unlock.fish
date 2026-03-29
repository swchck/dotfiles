# Description: Unlock an application by removing the quarantine attribute
# Usage: unlock <app-name>
# Example: unlock "Google Chrome"

function unlock
    if not test (uname) = "Darwin"
        echo "Error: macOS only"
        return 1
    end

    if test (count $argv) -eq 0
        echo "Usage: unlock <app-name or path>"
        echo "Example: unlock 'Google Chrome'"
        return 1
    end

    # If argument looks like a path, use directly; otherwise search in /Applications
    set -l app_path "$argv"
    if not string match -q '/*' "$app_path"
        set app_path "/Applications/$app_path.app"
    end

    if not test -d "$app_path"
        echo "Error: $app_path is not a valid directory"
        return 1
    end

    set -l app_name (basename "$app_path")
    echo "Unlocking $app_name"
    sudo xattr -rd com.apple.quarantine "$app_path"
    echo "Unlocked $app_name"
end
