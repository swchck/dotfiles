# Description: Show local IP address
function localip
    ipconfig getifaddr en0 2>/dev/null; or ipconfig getifaddr en1 2>/dev/null; or echo "No network"
end
