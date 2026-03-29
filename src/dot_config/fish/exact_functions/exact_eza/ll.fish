# Description: Detailed list with header, hidden files and git status
function ll
    eza -l --all --group-directories-first --git --icons --header $argv
end
