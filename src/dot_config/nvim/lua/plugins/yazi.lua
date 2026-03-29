return { -- Yazi file manager integration for Neovim
    "mikavilpas/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    keys = {
        { "<leader>-", "<cmd>Yazi<cr>", desc = "Open Yazi at current file" },
        { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Open Yazi in cwd" },
        { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume last Yazi session" },
    },
    opts = {
        open_for_directories = false,
        keymaps = {
            show_help = "<f1>",
        },
    },
}
