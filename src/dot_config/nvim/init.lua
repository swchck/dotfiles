-- [[ Configure Basic Neovim Settings ]]

require 'core.options'
require 'core.keymaps'

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system(
        {
            "git", "clone", "--filter=blob:none",
            "--branch=stable", lazyrepo, lazypath
        }
    )
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)


-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- Plugins can be added with a link (or for a github repo: 'owner/repo' link).
-- Also, plugins can be added by using a table, with the first argument being the link
-- and the following keys can be used to configure plugin behavior/loading/etc.
require("lazy").setup({
    "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
    "fatih/vim-go",     -- Go language support

    require 'plugins.theme',
    require 'plugins.neotree',
    require 'plugins.whichkey',
    require 'plugins.telescope',
    require 'plugins.lazydev',
    require 'plugins.luvitmeta',
    require 'plugins.mason',
    require 'plugins.conform',
    require 'plugins.nvim_smp',
    require 'plugins.todo',
    require 'plugins.mini',
    require 'plugins.treesitter',
    require 'plugins.copilotchat',
    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',
    -- require 'kickstart.plugins.lint',
    -- require 'kickstart.plugins.autopairs',
}, {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            cmd = "⌘",
            config = "🛠",
            event = "📅",
            ft = "📂",
            init = "⚙",
            keys = "🗝",
            plugin = "🔌",
            runtime = "💻",
            require = "🌙",
            source = "📄",
            start = "🚀",
            task = "📌",
            lazy = "💤 ",
        },
    },
})

require 'core.autocommands'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
