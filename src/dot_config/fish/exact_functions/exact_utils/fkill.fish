# Description: Interactive process killer using fzf
function fkill
    set -l pid (procs --no-header | fzf --header="Select process to kill" --preview="echo {}" | awk '{print $1}')
    if test -n "$pid"
        echo "Killing PID $pid"
        kill $pid; or sudo kill $pid
    end
end
