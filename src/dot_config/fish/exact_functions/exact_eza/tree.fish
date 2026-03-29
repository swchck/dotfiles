# Description: Tree view with icons (default depth: 2)
function tree
    eza --tree --level=2 --all --long --header --icons --git $argv
end
