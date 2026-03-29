# Completions for pkill — suggest running process names with PID
complete -c pkill -f -a '(command ps -eo pid=,comm= 2>/dev/null | command awk "{printf \"%s\\tPID: %s\\n\", \$2, \$1}" | command sort -u)'
