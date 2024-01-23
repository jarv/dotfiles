return {
	{
		'rose-pine/neovim',
		lazy = false,
		priority = 1500,
		config = function()
			-- Setting the colorscheme must happen after the airline is loaded
			-- or buffers won't show in the tabline
			-- https://github.com/vim-airline/vim-airline/issues/2548#issuecomment-1786260443
			require('rose-pine').setup({

				styles = {
						bold = true,
						italic = false,
						transparency = false,
				},

				variant = "auto", -- auto, main, moon, or dawn
				dark_variant = "main", -- main, moon, or dawn
				dim_inactive_windows = false,
				extend_background_behind_borders = true,
			})

			vim.cmd('colorscheme rose-pine')
		end,
	},
}
