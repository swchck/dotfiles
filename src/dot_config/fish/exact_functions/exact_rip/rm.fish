# Description: Safe rm replacement using rip2 (sends to graveyard instead of deleting)
function rm
    rip2 $argv
end
