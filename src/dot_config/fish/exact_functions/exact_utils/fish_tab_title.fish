# Description: Short terminal TAB title (fish 4.2+), distinct from the window title.
# Gives the WezTerm tabline a compact label: the running command, else the cwd.
function fish_tab_title
    if set -q argv[1]; and test -n "$argv[1]"
        echo -- (string sub -l 20 -- $argv[1])
    else
        echo -- (prompt_pwd)
    end
end
