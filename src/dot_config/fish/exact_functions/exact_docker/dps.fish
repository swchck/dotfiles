# Description: Pretty docker ps output
function dps
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}" $argv
end
