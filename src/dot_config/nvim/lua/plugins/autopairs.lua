return { -- Auto-close brackets, quotes, etc.
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
        require("nvim-autopairs").setup({})
        -- Integrate with nvim-cmp: auto-add parentheses after function completion
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
}
