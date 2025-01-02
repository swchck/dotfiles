# Description: Toggle TTL value between 64 and 65

# Function: tgttl
# This function toggles the TTL (Time To Live) value between 64 and 65.
# TTL is a field in the IP packet that tells the network how long the packet should be allowed to circulate.
# This function checks the current TTL value and switches it to the other value.
function tgttl
    # Check the current TTL value
    if test (sysctl -n net.inet.ip.ttl) -eq 64
        # If TTL is 64, change it to 65
        sudo sysctl -w net.inet.ip.ttl=65
        echo "TTL value changed to 65"
    else
        # If TTL is not 64, change it to 64
        sudo sysctl -w net.inet.ip.ttl=64
        echo "TTL value changed to 64"
    end
end
