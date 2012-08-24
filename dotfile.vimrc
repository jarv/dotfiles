syntax on
filetype indent on
set et
set sw=4
set smarttab
set laststatus=2
set statusline=%F%m%r%h%w\ ~%Y~%=%4l,%2v\ [%L]
set tags=~/.TAGS
set nobackup
nmap ,p :w\|!python %
nmap ,t :!(find ~/src  -type f \( -name '*.py' -o -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.js" -o -name "*.pl" -o -name "*.pm" -o -name "*.html" -o -name "*.css" -o -name "*.htm" -o -name "*.php" -o -name "*.py" \) -exec ctags -o ~/.TAGS -a {} \;)&
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
