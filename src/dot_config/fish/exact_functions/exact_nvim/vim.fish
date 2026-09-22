# Description: vim points at neovim, not the macOS system vim
function vim --wraps nvim
    nvim $argv
end
