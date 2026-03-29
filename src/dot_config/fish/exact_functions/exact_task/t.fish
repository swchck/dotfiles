# Description: go-task shortcut (only where Taskfile exists)
function t
    # Check for Taskfile in current or parent directories
    set -l dir (pwd)
    while test "$dir" != "/"
        if test -f "$dir/Taskfile.yml" -o -f "$dir/Taskfile.yaml" -o -f "$dir/taskfile.yml" -o -f "$dir/taskfile.yaml"
            task $argv
            return
        end
        set dir (dirname $dir)
    end
    echo "No Taskfile found"
    return 1
end
