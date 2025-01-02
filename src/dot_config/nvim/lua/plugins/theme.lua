return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	init = function()
		require("catppuccin").setup({
			transparent_background = true,
		})

		vim.cmd.colorscheme("catppuccin-macchiato")
		vim.cmd.hi("Comment gui=none")
	end,
}