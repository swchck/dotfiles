# Description: Shortener for bandwhich - a CLI utility for displaying current network utilization by process, connection and remote IP/hostname
function bw
    # Check if 'bandwhich' is installed
    if not type -q bandwhich
        echo "Error: 'bandwhich' is not installed. Please install it first."
        return 1
    end

    echo "Bandwidth need root access to run. Please enter your password."
    sudo bandwhich $argv
end
