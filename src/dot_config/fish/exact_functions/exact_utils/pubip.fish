# Description: Show public IP address
function pubip
    curl -s https://ifconfig.me
    echo
end
