# Description: A function to cd multiple directories up
#
# Function: multicd
# This function takes a string of dots and changes the directory by the number of dots.
# For example, `..` will change the directory one level up, `...` 
# will change the directory two levels up, and so on.
function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end

# Register the multicd function as an abbreviation.
abbr --add dotdot --regex '^\.\.+$' --function multicd
