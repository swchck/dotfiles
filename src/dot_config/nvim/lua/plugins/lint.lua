return { -- Async linting (complements LSP diagnostics)
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            go = { "golangcilint" },
            python = { "ruff" },
            -- javascript = { "eslint_d" },
            -- typescript = { "eslint_d" },
            -- fish = { "fish" },
            -- sh = { "shellcheck" },
            -- dockerfile = { "hadolint" },
        }

        -- Auto-lint on save and insert leave
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                -- Only lint if linter is available
                local ft = vim.bo.filetype
                local linters = lint.linters_by_ft[ft] or {}
                for _, linter in ipairs(linters) do
                    if vim.fn.executable(linter) == 1 then
                        lint.try_lint()
                        return
                    end
                end
            end,
        })

        vim.keymap.set("n", "<leader>cl", function()
            lint.try_lint()
        end, { desc = "[C]ode [L]int" })
    end,
}
