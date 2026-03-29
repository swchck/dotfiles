# Description: Toggle TTL value between 64 and 65 (macOS only)
function tgttl
    if not test (uname) = "Darwin"
        echo "Error: macOS only"
        return 1
    end

    if test (sysctl -n net.inet.ip.ttl) -eq 64
        sudo sysctl -w net.inet.ip.ttl=65
        echo "TTL value changed to 65"
    else
        sudo sysctl -w net.inet.ip.ttl=64
        echo "TTL value changed to 64"
    end
end
