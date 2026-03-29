# Description: Interactive process killer using fzf (user processes only)
function fkill
    set -l uid (id -u)
    set -l pid (command ps -o pid=,comm= -U $uid 2>/dev/null | \
        command awk '{gsub(/.*\//, "", $2); printf "%7s  %s\n", $1, $2}' | \
        fzf --header="    PID  COMMAND  |  Enter: kill  Ctrl-K: force kill" \
            --bind "ctrl-k:execute-silent(kill -9 {1})+abort" | \
        command awk '{print $1}')

    if test -n "$pid"
        echo "Killing PID $pid (SIGTERM)..."
        kill -15 $pid 2>/dev/null
        sleep 1
        if kill -0 $pid 2>/dev/null
            echo "Still alive, sending SIGKILL..."
            kill -9 $pid 2>/dev/null; or sudo kill -9 $pid 2>/dev/null
        end
    end
end
