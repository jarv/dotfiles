vim.cmd([[
	set tabstop=2
	set shiftwidth=2
	set expandtab
	" set scrolloff=5
	set mouse-=a
	set mouse=""
	set nocompatible   " Disable vi-compatibility
	" set laststatus=2   " Always show the statusline
	set encoding=utf-8 " Necessary to show Unicode glyphs
	set undofile
	set undodir=~/.vim/undo/
	" sane handling of tabs
	set et
	set sw=2
	set smarttab
	set relativenumber
	set number

	" Fold behavior
	" let javaScript_fold=1         " JavaScript
	" let perl_fold=1               " Perl
	" let php_folding=1             " PHP
	" let r_syntax_folding=1        " R
	" let ruby_fold=1               " Ruby
	" let sh_fold_enabled=1         " sh
	" let vimsyn_folding='af'       " Vim script
	" let xml_syntax_folding=1      " XML
	" let yaml_syntax_folding=1      " XML

	" Backups

	set backup
	set backupdir=~/tmp
	set backupskip=/tmp/*,/private/tmp/*,~/.ssh/*
	set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
	set writebackup

	if executable('rg')
		set grepprg=rg\ --color=never
	endif

	function! AutoRestoreWinView()
	    let buf = bufnr("%")
	    if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
		let v = winsaveview()
		let atStartOfFile = v.lnum == 1 && v.col == 0
		if atStartOfFile && !&diff
		    call winrestview(w:SavedBufView[buf])
		endif
		unlet w:SavedBufView[buf]
	    endif
	endfunction


	function! AutoSaveWinView()
	    if !exists("w:SavedBufView")
		let w:SavedBufView = {}
	    endif
	    let w:SavedBufView[bufnr("%")] = winsaveview()
	endfunction

	" When switching buffers, preserve window view.
	autocmd BufLeave * call AutoSaveWinView()
	autocmd BufEnter * call AutoRestoreWinView()

	" pip install neovim pillow
	let g:python3_host_prog = "/opt/homebrew/bin/python3"

]])
