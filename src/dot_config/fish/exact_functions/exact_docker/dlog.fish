# Description: Follow docker container logs (interactive select with fzf)
function dlog
    if test (count $argv) -gt 0
        docker logs -f $argv
    else
        set -l container (docker ps --format "{{.Names}}" | fzf --header="Select container")
        if test -n "$container"
            docker logs -f $container
        end
    end
end
