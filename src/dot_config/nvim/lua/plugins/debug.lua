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
        "mfussenegger/nvim-dap-python",
    },
    keys = {
        -- Session
        { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
        { "<S-F5>", function() require("dap").terminate() end, desc = "Debug: Stop" },
        { "<C-F5>", function() require("dap").restart() end, desc = "Debug: Restart" },

        -- Stepping
        { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
        { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
        { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },

        -- Breakpoints
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
        { "<leader>dB", function()
            require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, desc = "Debug: Conditional Breakpoint" },
        { "<leader>dp", function()
            require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end, desc = "Debug: Log Point" },
        { "<leader>dx", function() require("dap").clear_breakpoints() end, desc = "Debug: Clear All Breakpoints" },

        -- UI
        { "<leader>dt", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
        { "<leader>de", function() require("dapui").eval() end, desc = "Debug: Eval Expression", mode = { "n", "v" } },
        { "<leader>df", function() require("dapui").float_element() end, desc = "Debug: Float Element" },

        -- Run
        { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
        { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: Toggle REPL" },

        -- Go-specific
        { "<leader>dgt", function() require("dap-go").debug_test() end, desc = "Debug: Go Test" },
        { "<leader>dgl", function() require("dap-go").debug_last_test() end, desc = "Debug: Go Last Test" },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- ── Mason: auto-install debug adapters ──────────────────────────

        require("mason-nvim-dap").setup({
            automatic_installation = true,
            ensure_installed = {
                "delve",            -- Go
                "debugpy",          -- Python
                -- "js-debug-adapter", -- JS/TS
            },
        })

        -- ── DAP UI ──────────────────────────────────────────────────────

        dapui.setup({
            icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
            layouts = {
                {
                    elements = {
                        { id = "scopes", size = 0.35 },
                        { id = "breakpoints", size = 0.15 },
                        { id = "stacks", size = 0.25 },
                        { id = "watches", size = 0.25 },
                    },
                    position = "left",
                    size = 40,
                },
                {
                    elements = {
                        { id = "repl", size = 0.5 },
                        { id = "console", size = 0.5 },
                    },
                    position = "bottom",
                    size = 10,
                },
            },
            controls = {
                icons = {
                    pause = "⏸",
                    play = "▶",
                    step_into = "⏎",
                    step_over = "⏭",
                    step_out = "⏮",
                    step_back = "◁",
                    run_last = "▶▶",
                    terminate = "⏹",
                    disconnect = "⏏",
                },
            },
            floating = {
                max_height = 0.9,
                max_width = 0.5,
                border = "rounded",
            },
        })

        -- Virtual text (show variable values inline)
        require("nvim-dap-virtual-text").setup({
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
            -- virt_text_pos = "eol",
        })

        -- Auto open/close DAP UI on debug session
        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close

        -- Breakpoint signs
        vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpoint", linehl = "", numhl = "" })
        vim.fn.sign_define("DapLogPoint", { text = "◇", texthl = "DapLogPoint", linehl = "", numhl = "" })
        vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
        vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })

        -- ── Go ──────────────────────────────────────────────────────────

        require("dap-go").setup({
            -- Additional dap configurations
            dap_configurations = {
                {
                    type = "go",
                    name = "Debug Package",
                    request = "launch",
                    program = "${fileDirname}",
                },
                {
                    type = "go",
                    name = "Debug Test (go.mod root)",
                    request = "launch",
                    mode = "test",
                    program = "./${relativeFileDirname}",
                },
                {
                    type = "go",
                    name = "Attach to Process",
                    request = "attach",
                    mode = "local",
                    processId = require("dap.utils").pick_process,
                },
            },
            delve = {
                path = "dlv",
                initialize_timeout_sec = 20,
                port = "${port}",
                args = {},
                build_flags = "",
                detached = vim.fn.has("win32") == 0,
            },
        })

        -- ── Python ──────────────────────────────────────────────────────

        require("dap-python").setup("python3")

        -- Additional Python configurations
        table.insert(dap.configurations.python, {
            type = "python",
            request = "launch",
            name = "Debug Current File",
            program = "${file}",
            console = "integratedTerminal",
        })
        table.insert(dap.configurations.python, {
            type = "python",
            request = "launch",
            name = "Debug with Arguments",
            program = "${file}",
            args = function()
                local args_string = vim.fn.input("Arguments: ")
                return vim.split(args_string, " +")
            end,
            console = "integratedTerminal",
        })
        table.insert(dap.configurations.python, {
            type = "python",
            request = "launch",
            name = "Debug Module",
            module = function()
                return vim.fn.input("Module name: ")
            end,
            console = "integratedTerminal",
        })

        -- ── JS/TS (uncomment when needed) ───────────────────────────────

        -- dap.adapters["pwa-node"] = {
        --     type = "server",
        --     host = "localhost",
        --     port = "${port}",
        --     executable = {
        --         command = "node",
        --         args = { vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js", "${port}" },
        --     },
        -- }
        -- for _, lang in ipairs({ "javascript", "typescript" }) do
        --     dap.configurations[lang] = {
        --         {
        --             type = "pwa-node",
        --             request = "launch",
        --             name = "Launch file",
        --             program = "${file}",
        --             cwd = "${workspaceFolder}",
        --         },
        --         {
        --             type = "pwa-node",
        --             request = "attach",
        --             name = "Attach",
        --             processId = require("dap.utils").pick_process,
        --             cwd = "${workspaceFolder}",
        --         },
        --     }
        -- end
    end,
}
