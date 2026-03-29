# Description: Jump to repository root
function repo
    if test (count $argv) -eq 0
        cd ~/.repository
    else
        cd ~/.repository/$argv[1]
    end
end
