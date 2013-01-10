call pathogen#infect()
syntax enable
" set background=dark
" let g:solarized_termcolors=256
" colorscheme solarized
filetype plugin indent on

if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
  endif
  set encoding=utf-8
  setglobal fileencoding=utf-8
  "setglobal bomb
  set fileencodings=ucs-bom,utf-8,latin1
endif

" Update helpfiles

Helptags

" Beter colors for omnicomplete popup
highlight Pmenu ctermbg=238 gui=bold

" Indexer options

let g:indexer_disableCtagsWarning=1

" Powerline configuration https://github.com/Lokaltog/vim-powerline

set nocompatible   " Disable vi-compatibility
set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs
let g:Powerline_symbols = 'fancy'

" Syntastic configuration

let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'
let g:syntastic_mode_map = { 'mode': 'active',
                            \ 'passive_filetypes': 
                            \    ['puppet', 'python', 'javascript'] }
nmap ,s :SyntasticCheck<cr>
nmap ,t :SyntasticToggleMode<cr>
nmap ,e :Errors<cr>

" Ctrlp configuration
nmap \b :CtrlPBuffer<cr>
nmap \f :CtrlPBuffer<cr>
nmap \h :help ctrlp.txt<cr>
let g:ctrlp_custom_ignore = '\v[\/](\.git|\.hg|\.svn)$'

" Fugitive (git) configuration

nmap ,g :Gstatus<cr>
nmap ,P :Git push<cr>

" Turn on omni completion

set ofu=syntaxcomplete#Complete

" Sane handling of tabs

set et
set sw=4
set smarttab
" yaml, puppet, HTML uses 2 space indent
autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
autocmd FileType puppet setlocal shiftwidth=2 tabstop=2
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2

" Additional shortcuts
nmap ,c :q<cr>
nmap ,q  :tabdo q!<cr>
nmap ,wq :tabdo wq<cr>
nmap ,p  :set paste<cr>
nmap ,n :set nopaste<cr>
nmap ,# :s/^/#
nmap ,3 :s/^#//

nmap <C-k> :tabn<cr>
nmap <C-j> :tabp<cr>

" Reverse join
nnoremap ,j ddpgkJ 

" Copy and paste to the system clipboard

nnoremap <C-y> "+y
vnoremap <C-y> "+y
" nnoremap <C-T> "+p
" vnoremap <C-T> "+p

" Fold behavior

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


" Remove trailing whitespace automatically for python files
autocmd BufWritePre *.py :%s/\s\+$//e
autocmd BufWritePre *.pp :%s/\s\+$//e

" backups

set backup 
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp 
set backupskip=/tmp/*,/private/tmp/*,~/.ssh/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp 
set writebackup
