# Description: Pretty print $PATH, one entry per line
# (named `showpath`, not `path`, to avoid shadowing fish's built-in `path`)
function showpath
    string split : $PATH | nl
end
