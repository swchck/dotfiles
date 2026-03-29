# Description: Delete zellij session with fzf
function zld
    set -l lines (zellij list-sessions --no-formatting 2>/dev/null)
    if test -z "$lines"
        echo "No zellij sessions found"
        return 1
    end

    set -l selected (for line in $lines
        set -l name (echo $line | command awk '{print $1}')
        set -l info (echo $line | command sed "s/^$name //")
        printf "%-20s %s\n" $name $info
    end | fzf --header="NAME                 INFO  |  Enter: delete  (active sessions force-killed)")

    if test -n "$selected"
        set -l name (echo $selected | command awk '{print $1}')
        zellij delete-session --force $name
        echo "Deleted session: $name"
    end
end
