return { -- Visual indent guides
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
        indent = {
            char = "│",
            -- tab_char = "│",
        },
        scope = {
            enabled = true,
            show_start = false,
            show_end = false,
        },
        exclude = {
            filetypes = {
                "help",
                "dashboard",
                "neo-tree",
                "Trouble",
                "trouble",
                "lazy",
                "mason",
                "notify",
                "toggleterm",
            },
        },
    },
}
