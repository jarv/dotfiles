-- Hides dos line-endings, for any file located in */node_modules/*
-- Checks only the first 10 lines
vim.api.nvim_exec([[
	augroup NodeModulesAutocmd
			autocmd!
			autocmd BufWinEnter */node_modules/* call CheckForDos()
	augroup END

	function! CheckForDos()
		for i in range(1, line('$'))
			if i >= 10
					break
			endif
			if char2nr(getline(i)[-1:-1]) == 13
				e ++ff=dos
				break
			endif
		endfor
	endfunction
]], false)
