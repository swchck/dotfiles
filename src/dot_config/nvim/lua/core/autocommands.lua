-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Recognize GitLab CI files as `yaml.gitlab` so gitlab-ci-ls attaches.
-- Must be registered before any buffer is opened.
vim.filetype.add({
	pattern = {
		[".*/%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
		[".*%.gitlab%-ci.*%.ya?ml"] = "yaml.gitlab",
	},
})