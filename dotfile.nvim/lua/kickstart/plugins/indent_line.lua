return {
	{ -- Add indentation guides even on blank lines
		"lukas-reineke/indent-blankline.nvim",
		-- Enable `lukas-reineke/indent-blankline.nvim`
		-- See `:help ibl`
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = { char = "" },
			})
		end,
		opts = {},
	},
}
-- vim: ts=2 sts=2 sw=2 et
