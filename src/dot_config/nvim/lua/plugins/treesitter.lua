return { -- Highlight, edit, and navigate code (nvim-treesitter main-branch API)
    "nvim-treesitter/nvim-treesitter",
    -- The rewrite (main branch, now default) dropped `configs.setup{ highlight,
    -- indent, ensure_installed, auto_install }`. Parsers are installed
    -- imperatively; highlighting is vim.treesitter.start() per buffer; indent
    -- is the experimental indentexpr. main does not support lazy-loading.
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local parsers = {
            "bash",
            "c",
            "css",
            "diff",
            "dockerfile",
            "fish",
            "go",
            "gomod",
            "gosum",
            "html",
            "javascript",
            "json",
            "lua",
            "luadoc",
            "markdown",
            "markdown_inline",
            "proto",
            "python",
            "query",
            "rust",
            "sql",
            "toml",
            "typescript",
            "vim",
            "vimdoc",
            "yaml",
        }
        require("nvim-treesitter").install(parsers)

        -- Enable Treesitter highlighting + experimental indent for any buffer
        -- whose filetype has a parser installed. pcall guards filetypes without
        -- one (replaces the old per-language enable/disable lists). There is no
        -- auto_install on main — add parsers above or run :TSInstall <lang>.
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
            callback = function(args)
                if pcall(vim.treesitter.start, args.buf) then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
    -- Additional modules to explore:
    --    - Incremental selection: `:help nvim-treesitter-incremental-selection-mod`
    --    - Context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
