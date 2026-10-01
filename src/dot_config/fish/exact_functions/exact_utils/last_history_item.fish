# Description: Execute last command via !!

# Function: last_history_item
# This function retrieves and echoes the last command from the history.
# It uses the 'history' command to access the command history and
# echoes the most recent command.
function last_history_item
    echo $history[1]
end

abbr -a !! --position anywhere --description="previous command" --function last_history_item
