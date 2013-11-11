call pathogen#infect()
syntax enable
" set background=dark
" let g:solarized_termcolors=256
" colorscheme solarized
filetype plugin indent on
au BufRead,BufNewFile *.config set filetype=yaml
au BufRead,BufNewFile *.scss set filetype=sass
au BufRead,BufNewFile *.j2 set filetype=jinja
if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
  endif
  set encoding=utf-8
  setglobal fileencoding=utf-8
  "setglobal bomb
  set fileencodings=ucs-bom,utf-8,latin1
endif
" change the mapleader from \ to ,
let mapleader=","

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
let g:syntastic_python_flake8_args='--ignore=E501'
let g:syntastic_python_pep8_args='--ignore=E501'
let g:syntastic_mode_map = { 'mode': 'active',
                            \ 'passive_filetypes': 
                            \    ['puppet', 'python', 'javascript'] }
nmap <leader>s :SyntasticCheck<cr>
nmap <leader>t :SyntasticToggleMode<cr>
nmap <leader>e :Errors<cr>

" Ctrlp configuration
nmap <leader>b :CtrlPBuffer<cr>
nmap <leader>m :CtrlPMRU<cr>
nmap <leader>h :help ctrlp.txt<cr>
let g:ctrlp_custom_ignore = '\v[\/](\.git|\.hg|\.svn)$'
" Open new files in tabs
set tabpagemax=50
let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }

" Fugitive (git) configuration

nmap <leader>g :Gstatus<cr>
nmap <leader>P :Git push<cr>

" Turn on omni completion

set ofu=syntaxcomplete#Complete

" Sane handling of tabs

set et
set sw=4
set smarttab

" 2 space indents :(
autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
autocmd FileType puppet setlocal shiftwidth=2 tabstop=2
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2

" Additional shortcuts
nmap <leader>c :q<cr>
nmap <leader>q  :tabdo q!<cr>
nmap <leader>wq :tabdo wq<cr>
nmap <leader>p  :set paste<cr>
nmap <leader>n :set nopaste<cr>
nmap <leader># :s/^/#
nmap <leader>3 :s/^#//
" Quote a word
nnoremap qw :silent! normal mpea'<Esc>bi'<Esc>`pl
" double quote a word
nnoremap qd :silent! normal mpea"<Esc>bi"<Esc>`pl
" remove quotes from a word
nnoremap wq :silent! normal mpeld bhd `ph<CR>

nmap <C-k> :tabn<cr>
nmap <C-j> :tabp<cr>

" Reverse join
nnoremap ,j ddpgkJ 

" Copy and paste to the system clipboard

" nnoremap <C-y> "+y
" vnoremap <C-y> "+y
" nnoremap <C-p> "+p
" vnoremap <C-p> "+p

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
autocmd BufWritePre *.yml :%s/\s\+$//e
autocmd BufWritePre *.yaml :%s/\s\+$//e
autocmd BufWritePre *.pp :%s/\s\+$//e

" backups

set backup 
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp 
set backupskip=/tmp/*,/private/tmp/*,~/.ssh/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp 
set writebackup
