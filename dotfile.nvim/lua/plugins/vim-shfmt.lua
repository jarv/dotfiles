return {
	"z0mbix/vim-shfmt",
	config = function()
		vim.cmd([[
						let g:shfmt_extra_args = '-i 2 -ci'
		]])
	end
}
