# Description: Detailed list with hidden files and git status
function l
    eza -l --all --group-directories-first --git --icons $argv
end
