# Description: ls replacement using eza
function ls
    eza --group-directories-first --icons --color=always $argv
end
