# Description: Execute last command via !!

# Function: last_history_item
# This function retrieves and echoes the last command from the history.
# It uses the 'history' command to access the command history and
# echoes the most recent command.
function last_history_item
    echo $history[1]
end

# Abbreviation: !!
# This abbreviation allows you to quickly execute the last command
# by typing '!!'. It uses the 'last_history_item' function to retrieve
# the last command from the history.
abbr -a !! --position anywhere --function last_history_item
