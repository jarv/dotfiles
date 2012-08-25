call pathogen#infect()
syntax on
filetype plugin indent on

" Powerline configuration https://github.com/Lokaltog/vim-powerline

set nocompatible   " Disable vi-compatibility
set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs
let g:Powerline_symbols = 'fancy'

" Syntastic configuration

let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'
let g:syntastic_mode_map = { 'mode': 'active',
                            \ 'passive_filetypes': ['puppet', 'python'] }
nmap ,s :SyntasticCheck<cr>
nmap ,t :SyntasticToggleMode<cr>
nmap ,e :Errors<cr>

" Ctrlp configuration
nmap \b :CtrlPBuffer<cr>
nmap \f :CtrlPBuffer<cr>
nmap \h :help ctrlp.txt<cr>


set et
set sw=4
set smarttab
set tags=~/.TAGS
set nobackup

nmap ,p :w\|!python %
nmap ,q  :tabdo q!<cr>
nmap ,wq :tabdo wq<cr>
nmap ,p  :set paste<cr>
nmap ,n :set nopaste<cr>
nmap <C-k> :tabn<cr>
nmap <C-j> :tabp<cr>

set foldmethod=syntax
set foldlevelstart=1

let javaScript_fold=1         " JavaScript
let perl_fold=1               " Perl
let php_folding=1             " PHP
let r_syntax_folding=1        " R
let ruby_fold=1               " Ruby
let sh_fold_enabled=1         " sh
let vimsyn_folding='af'       " Vim script
let xml_syntax_folding=1      " XML

autocmd FileType html setlocal shiftwidth=2 tabstop=2
