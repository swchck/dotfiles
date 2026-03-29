# Description: cd replacement using zoxide (fuzzy match with fallback to real cd)
function cd
    if test (count $argv) -eq 0
        z ~
    else if test -d "$argv[1]"
        z $argv
    else
        z $argv
    end
end
