# Description: Plain bat output (no decorations, always colored)
function pcat
    bat --style=plain --color=always --paging=never $argv
end
