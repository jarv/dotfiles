return {
	"bling/vim-airline",
	lazy = false,
	priority = 500,
	config = function()
		vim.cmd([[
				let g:Powerline_symbols = 'fancy'
				let g:airline#extensions#tabline#enabled = 1
				let g:airline_powerline_fonts = 1
				let g:airline#extensions#gutentags#enabled = 1
				let g:airline#extensions#ale#enabled = 1
		]])
	end
}
