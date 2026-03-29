# Description: Pretty docker ps output
function dps
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.State}}\t{{.Status}}" $argv
end
