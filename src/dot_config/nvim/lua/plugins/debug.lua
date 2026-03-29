return { -- DAP (Debug Adapter Protocol) for Neovim
    "mfussenegger/nvim-dap",
    dependencies = {
        -- UI for DAP
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",

        -- Virtual text for variables
        "theHamsta/nvim-dap-virtual-text",

        -- Mason integration for debug adapters
        "jay-babu/mason-nvim-dap.nvim",

        -- Language-specific
        "leoluz/nvim-dap-go",
    },
    keys = {
        { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
        { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
        { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
        { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debug: Conditional Breakpoint" },
        { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
        { "<leader>dt", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- Install debug adapters via Mason
        require("mason-nvim-dap").setup({
            automatic_installation = true,
            ensure_installed = {
                "delve",    -- Go
                -- "debugpy",  -- Python
                -- "js-debug-adapter",  -- JS/TS
            },
        })

        -- DAP UI setup
        dapui.setup({
            icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
            controls = {
                icons = {
                    pause = "⏸",
                    play = "▶",
                    step_into = "⏎",
                    step_over = "⏭",
                    step_out = "⏮",
                    step_back = "b",
                    run_last = "▶▶",
                    terminate = "⏹",
                    disconnect = "⏏",
                },
            },
        })

        -- Virtual text
        require("nvim-dap-virtual-text").setup({})

        -- Auto open/close DAP UI
        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close

        -- Go debug setup
        require("dap-go").setup()
    end,
}
