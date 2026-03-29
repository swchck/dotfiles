# Description: Tree view with limited depth (default: 3)
function tre
    set -l depth 3
    if test (count $argv) -gt 0; and string match -qr '^\d+$' $argv[1]
        set depth $argv[1]
        set -e argv[1]
    end
    eza --tree --level=$depth --icons $argv
end
