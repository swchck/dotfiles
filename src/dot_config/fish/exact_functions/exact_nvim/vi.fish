# Description: vi points at neovim, not the macOS system vi
function vi --wraps nvim
    nvim $argv
end
