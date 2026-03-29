# Description: cat replacement using bat (no pager)
function cat
    bat --paging=never $argv
end
