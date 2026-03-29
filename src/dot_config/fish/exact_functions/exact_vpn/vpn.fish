# Description: Manage OpenFortiVPN connections (work)
# Usage: vpn [connect|disconnect|status] [-c|--config <path>]

function vpn
    set -l action ""
    set -l config_file $HOME/.config/openfortivpn/primary.conf

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case '-c' '--config'
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set config_file $argv[$i]
                else
                    echo "Error: --config requires a path argument"
                    return 1
                end
            case 'connect' 'c' 'disconnect' 'd' 'status' 's'
                set action $argv[$i]
            case '*'
                echo "Unknown argument: $argv[$i]"
                echo "Usage: vpn [connect|disconnect|status] [-c|--config <path>]"
                return 1
        end
        set i (math $i + 1)
    end

    set -l log_file $HOME/"$(basename $config_file).log"

    if test -z "$action"
        echo "Usage: vpn [connect|disconnect|status] [-c|--config <path>]"
        return 1
    end

    # Ensure sudo access
    if not sudo -n true 2>/dev/null
        echo "Please enter your sudo password. It's required for configuring VPN settings."
        sudo -v
    end

    if not sudo -n true 2>/dev/null
        echo "Error: sudo rights are required!"
        return 1
    end

    # Check configuration file exists
    if not test -f $config_file
        echo "Error: Configuration file not found: $config_file"
        return 1
    end

    switch $action
        case 'connect' 'c'
            if pgrep -x openfortivpn > /dev/null
                echo "VPN already connected"
            else
                sudo openfortivpn --config $config_file &> $log_file &
                echo "VPN connecting... (config: $config_file, log: $log_file)"
            end
        case 'disconnect' 'd'
            if pgrep -x openfortivpn > /dev/null
                sudo pkill -x openfortivpn
                echo "VPN disconnected"
            else
                echo "No active VPN connection found"
            end
        case 'status' 's'
            if pgrep -x openfortivpn > /dev/null
                echo "Connected (config: $config_file)"
            else
                echo "Disconnected"
            end
    end
end
