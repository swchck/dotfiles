return { -- File explorer as a buffer (edit filesystem like text)
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" },
    },
    opts = {
        -- Show hidden files
        view_options = {
            show_hidden = true,
        },
        -- Keymaps within oil buffer
        keymaps = {
            ["g?"] = "actions.show_help",
            ["<CR>"] = "actions.select",
            ["<C-v>"] = "actions.select_vsplit",
            ["<C-s>"] = "actions.select_split",
            ["<C-t>"] = "actions.select_tab",
            ["<C-p>"] = "actions.preview",
            ["q"] = "actions.close",
            ["-"] = "actions.parent",
            ["_"] = "actions.open_cwd",
            ["`"] = "actions.cd",
            ["~"] = "actions.tcd",
            ["gs"] = "actions.change_sort",
            ["gx"] = "actions.open_external",
            ["g."] = "actions.toggle_hidden",
            ["g\\"] = "actions.toggle_trash",
        },
        -- Use trash instead of permanent delete
        delete_to_trash = true,
        -- Skip confirmation for simple operations
        skip_confirm_for_simple_edits = true,
        -- Floating window for oil
        float = {
            padding = 2,
            max_width = 100,
            max_height = 30,
        },
    },
}
