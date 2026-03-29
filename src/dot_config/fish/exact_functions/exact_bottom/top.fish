# Description: Replace the `top` command with `btm`.
function top
    # Check if 'btm' is installed
    if not type -q btm
        echo "Error: 'btm' is not installed. Please install it first."
        return 1
    end

    btm
end

# Description: Replace the `htop` command with `btm`.
function htop
    top
end
