return {
	"google/vim-jsonnet",
	config = function()
		vim.cmd([[
				let g:jsonnet_fmt_options = '--string-style l'
				let g:jsonnet_fmt_on_save = 1
		]])
	end
}
