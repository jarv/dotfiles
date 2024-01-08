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
				variant = 'main',
				disable_italics = true,
				disable_background = true,
				disable_float_background = false,
			})

			vim.cmd('colorscheme rose-pine')
		end,
	},
}
