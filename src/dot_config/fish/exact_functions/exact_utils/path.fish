# Description: Pretty print $PATH, one entry per line
function path
    string split : $PATH | nl
end
