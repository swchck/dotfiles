# Description: ls replacement using eza
function ls
    eza --group-directories-first --icons --classify=auto --color=always $argv
end
