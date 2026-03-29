vim.o.wrap = false -- Do not wrap lines Default: true
vim.o.linebreak = true -- Wrap lines at convenient points Default: false
vim.o.mouse = "a" -- Enable mouse support Default: ""
vim.o.autoindent = true -- Automatically indent new lines Default: false
vim.o.ignorecase = true -- Ignore case when searching Default: false
vim.o.smartcase = true -- Use case when searching with uppercase Default: false
vim.o.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent Default: 8
vim.o.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for Default: 8
vim.o.expandtab = true -- Use spaces instead of tabs Default: false
vim.o.softtabstop = 4 -- Number of spaces that a <Tab> counts for while editing Default: 0
vim.o.scrolloff = 5 -- Number of lines to keep above and below the cursor Default: 0
vim.o.sidescrolloff = 8 -- Number of columns to keep to the left and right of the cursor Default: 0
vim.o.cursorline = true -- Highlight the current line Default: false
vim.o.splitbelow = true -- Put new windows below the current window Default: false
vim.o.splitright = true -- Put new windows right of the current window Default: false
vim.o.hlsearch = false -- Highlight search results Default: false
vim.o.showmode = false -- Do not show the mode Default: true
vim.o.whichwrap = "bs<>[]hl" -- Allow <BS>, <Space>, <CR>, and <Tab> to cross line boundaries Default: "b,s"
vim.o.numberwidth = 4 -- Set the width of the number column Default: 4
vim.o.swapfile = false -- Do not create swap files Default: true
vim.o.smartindent = true -- Do smart indenting when starting a new line Default: false
vim.o.showtabline = 2 -- Always show the tabline Default: 1
vim.o.backspace = "indent,eol,start" -- Allow backspacing over everything in insert mode Default: "indent,eol,start"
vim.o.pumheight = 10 -- Maximum number of items in the popup menu Default: 15
vim.o.conceallevel = 0 -- Show everything Default: 2
vim.o.fileencoding = "utf-8" -- Set the encoding of the file Default: "utf-8"
vim.o.cmdheight = 1 -- Set the height of the command line Default: 1
vim.wo.number = true -- Show line numbers on the left side Default: false
vim.wo.relativenumber = true -- Show relative line numbers on the left side Default: false
vim.wo.signcolumn = "yes" -- Always show the sign column Default: "auto"
vim.opt.termguicolors = true -- Enable true colors Default: false
vim.opt.breakindent = true -- Enable break indent Default: false
vim.opt.undofile = true -- Enable persistent undo Default: false
vim.opt.signcolumn = "yes" -- Always show the sign column Default: "auto"
vim.opt.updatetime = 250 -- Set the time in ms to write swap file Default: 4000
vim.opt.timeoutlen = 300 -- Set the time in ms to wait for a mapped sequence to complete Default: 1000
vim.opt.list = true -- Show some invisible characters Default: false
vim.opt.listchars = {
    tab = "» ",
    trail = "·",
    nbsp = "␣",
} -- Set the characters to be shown with 'list' option Default: {tab = ">", trail = ".", extends = ">", precedes = "<",nbsp = " "}
vim.opt.inccommand = "split" -- Show the effects of a command incrementally, as you type Default: ""


-- TODO: Add checking of existence of Nerd Font
vim.g.have_nerd_font = true -- Set to true if you have a Nerd Font installed Default: false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)
