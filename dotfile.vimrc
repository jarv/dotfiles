let g:python3_host_prog = "/opt/homebrew/bin/python3"

" vim plug
call plug#begin('~/.vim/plugged')
Plug 'rust-lang/rust.vim'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline'
Plug 'cakebaker/scss-syntax.vim'
Plug 'chase/vim-ansible-yaml'
Plug 'ervandew/supertab'
Plug 'fatih/vim-go'
Plug 'google/vim-jsonnet'
Plug 'hashivim/vim-terraform'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'pbogut/fzf-mru.vim'
Plug 'kchmck/vim-coffee-script'
Plug 'ludovicchabant/vim-gutentags'
Plug 'rlue/vim-fold-rspec'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'towolf/vim-helm'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/AnsiEsc.vim'
Plug 'z0mbix/vim-shfmt'
Plug 'zah/nim.vim'
Plug 'pedrohdz/vim-yaml-folds'
Plug 'ferrine/md-img-paste.vim'
Plug 'dense-analysis/ale'
Plug 'autozimu/LanguageClient-neovim'

" Typescript
Plug 'pangloss/vim-javascript'    " JavaScript support
Plug 'leafgarland/typescript-vim' " TypeScript syntax
Plug 'maxmellon/vim-jsx-pretty'   " JS and JSX syntax
Plug 'jparise/vim-graphql'        " GraphQL syntax

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" Initialize plugin system
call plug#end()

syntax enable
" minimum number of screen lines that you would like above and below the cursor
set scrolloff=5

"Fzf configuration
if executable('rg')
  let $FZF_DEFAULT_COMMAND= 'rg --files --hidden -g "!.git/*"'
endif

nmap <c-p> :Files<cr>

set re=1
set regexpengine=1
set ttyfast
set lazyredraw
"----------------
" Git Gutter"
set updatetime=250
let g:gitgutter_max_signs = 500
" No mapping
let g:gitgutter_map_keys = 0

" Colors
let g:gitgutter_override_sign_column_highlight = 0
highlight clear SignColumn
highlight GitGutterAdd ctermfg=2
highlight GitGutterChange ctermfg=3
highlight GitGutterDelete ctermfg=1
highlight GitGutterChangeDelete ctermfg=4

filetype plugin indent on
au BufRead,BufNewFile *.md set filetype=markdown
au BufRead,BufNewFile *.md.erb set filetype=markdown
au BufRead,BufNewFile *.config set filetype=yaml
au BufRead,BufNewFile *.scss set filetype=sass
au BufRead,BufNewFile *.j2 set filetype=jinja
au BufRead,BufNewFile *.yaml.gotmpl set filetype=yaml

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

" Beter colors for omnicomplete popup
highlight Pmenu ctermbg=darkblue ctermfg=white

" Pydiction options
let g:pydiction_location = '/home/jarv/.vim/bundle/pydiction/complete-dict'
" Indexer options

" Powerline configuration https://github.com/Lokaltog/vim-powerline
let g:gutentags_ctags_exclude = ['target', 'tmp', 'spec', 'node_modules', 'public', '*.json', '*.svg', '*.md']
let g:gutentags_exclude_filetypes=['markdown', 'json']
let g:gutentags_ctags_executable_ruby = 'rtags'

function! ShouldEnableGutentags(path) abort
    return fnamemodify(a:path, ':e') != 'go'
endfunction

let g:gutentags_enabled_user_func = 'ShouldEnableGutentags'

set nocompatible   " Disable vi-compatibility
set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs
let g:Powerline_symbols = 'fancy'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#gutentags#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_echo_msg_format = '%linter%: %s'

" Jsonnet configuration
let g:jsonnet_fmt_options = '--string-style l'
let g:jsonnet_fmt_on_save = 1

" ALE configuration
let g:ale_linters = {
  \ 'go': ['golangci-lint'],
  \ 'markdown':      ['mdl', 'writegood'],
  \ 'jsonnet':      ['jsonnset-lint'],
  \ 'yaml':      ['yamllint'],
  \ 'ruby': ['rubocop'],
  \ 'sh': ['shellcheck'],
  \ 'javascript': ['eslint'],
\}

let g:ale_fixers = {
  \ 'python': ['black'],
  \ 'go': ['gofmt'],
  \ '*': ['remove_trailing_lines', 'trim_whitespace'],
  \ 'javascript': ['prettier'],
  \ 'typescript': ['prettier'],
\}

let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_ruby_rubocop_options = '-D'
let g:ale_markdown_markdownlint_options = '-c /Users/jarv/.markdownlint.json'
let g:ale_sh_shellcheck_options = '-e SC1090,SC1091'
let g:ale_python_flake8_options = '--ignore=E501'
let g:ale_python_pep8_options = '--ignore=E501'
let g:ale_markdown_mdl_options = '~MD013'
let g:ale_javascript_prettier_options = '--single-quote --trailing-comma all'

highlight ALEErrorSign ctermbg        =NONE ctermfg=red
highlight ALEWarningSign ctermbg      =NONE ctermfg=yellow
let g:ale_sign_warning = '⚠'
let g:ale_sign_error = '✘'
let g:ale_fix_on_save = 1
let g:ale_go_golangci_lint_options = ''
let g:ale_go_golangci_lint_package = 1
" go-vim configuration
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1
" let g:go_auto_sameids = 1
let g:go_addtags_transform = "snakecase"

" Turn on omni completion
set ofu=syntaxcomplete#Complete

" Sane handling of tabs
set et
set sw=2
set smarttab

" Terraform fmt
let g:terraform_fmt_on_save=1
let g:terraform_fold_sections=1

" file specific indents
autocmd FileType html setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType eruby setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType htmldjango setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType yml setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType puppet setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType javascript setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType coffee setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType markdown setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType terraform setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType jsonnet setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType json setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType sh setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType bash setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType *.gotmpl setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType go setlocal autoindent noexpandtab tabstop=4 shiftwidth=4
autocmd FileType make setlocal autoindent noexpandtab tabstop=4 shiftwidth=4
autocmd FileType yaml setl iskeyword+=#,-

" Paste images from the clipboard
autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
let g:mdip_imgdir_absolute="/Users/jarv/src/jarv.org/static/img"
let g:mdip_imdir_intext="/img"
" let g:mdip_imgdir="/Users/jarv/src/jarv.org/static/img"

nmap <leader>q :bd<cr>
nmap <leader>m :ProjectFiles<cr>
nmap <leader>. :Rg<cr>
nmap <leader><SPACE> :GF?<cr>
nmap <leader>s :ALEToggle<cr>
nmap <leader>g :Gstatus<cr>
nmap <leader>P :Git push<cr>
" Quote a word
" nnoremap qw :silent! normal mpea'<Esc>bi'<Esc>`pl
" double quote a word
" nnoremap qd :silent! normal mpea"<Esc>bi"<Esc>`pl
" remove quotes from a word
" nnoremap wq :silent! normal mpeld bhd `ph<CR>

" buffers
nmap <C-k> :bnext<cr>
nmap <C-j> :bprev<cr>
set hidden " Don't require saving when switching buffers

" Reverse join
nnoremap ,j ddpgkJ

" Fold behavior
let javaScript_fold=1         " JavaScript
let perl_fold=1               " Perl
let php_folding=1             " PHP
let r_syntax_folding=1        " R
let ruby_fold=1               " Ruby
let sh_fold_enabled=1         " sh
let vimsyn_folding='af'       " Vim script
let xml_syntax_folding=1      " XML
let yaml_syntax_folding=1      " XML
let yaml_syntax_folding=1      " XML

" Remove trailing whitespace automatically for some
" file types
autocmd BufWritePre *.py :%s/\s\+$//e
autocmd BufWritePre *.rb :%s/\s\+$//e
autocmd BufWritePre *.pp :%s/\s\+$//e
autocmd BufWritePre *.tf :%s/\s\+$//e
autocmd BufWritePre *.bash :%s/\s\+$//e
autocmd BufWritePre *.json :%s/\s\+$//e
autocmd BufWritePre *.sh :%s/\s\+$//e
autocmd BufWritePre *.bash :%s/\s\+$//e
autocmd BufWritePre *.md :%s/\s\+$//e
autocmd BufWritePre *.html :%s/\s\+$//e
autocmd BufWritePre *.rake :%s/\s\+$//e
autocmd BufWritePre *.erb :%s/\s\+$//e
autocmd BufWritePre *.gotmpl :%s/\s\+$//e
autocmd BufWritePre *.yaml :%s/\s\+$//e
autocmd BufWritePre *.yml :%s/\s\+$//e
autocmd BufWritePre yaml :%s/\s\+$//e
autocmd BufWritePre Rakefile :%s/\s\+$//e
autocmd BufWritePre bash :%s/\s\+$//e
autocmd BufWritePre sh :%s/\s\+$//e
autocmd BufWritePre gotmpl :%s/\s\+$//e

" backups
set backup
set backupdir=~/tmp
set backupskip=/tmp/*,/private/tmp/*,~/.ssh/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

" spelling
"
autocmd FileType latex,tex,md,markdown setlocal spell spelllang=en_us
autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us
autocmd BufRead,BufNewFile *.md.erb setlocal spell spelllang=en_us

if has("gui_macvim")
  let g:AutoPairsShortcutToggle     = 'č' " <m-p>
  let g:AutoPairsShortcutFastWrap   = '∑' " <m-w>
  let g:AutoPairsShortcutJump       = '∆' " <m-j>
  let g:AutoPairsShortcutBackInsert = '∫' " <m-b>
endif

if executable('rg')
  set grepprg=rg\ --color=never
endif

" bind K to grep word under cursor
nnoremap <silent> <Leader>r :Rg <C-R><C-W><CR>
" nnoremap K :Rg "\b<C-R><C-W>\b"<CR>:cw<CR>
" cmap q qa
let g:shfmt_extra_args = '-i 2 -ci'

" Save current view settings on a per-window, per-buffer basis.
function! AutoSaveWinView()
    if !exists("w:SavedBufView")
        let w:SavedBufView = {}
    endif
    let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" Restore current view settings.
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

" When switching buffers, preserve window view.
if v:version >= 700
    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()
endif

set undofile
set undodir=~/.vim/undo/

function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

command! ProjectFiles execute 'Files' s:find_git_root()

" Jump to tag
nn <M-g> :call JumpToDef()<cr>
ino <M-g> <esc>:call JumpToDef()<cr>i

" nvim-cmp
set completeopt=menu,menuone,noselect

lua <<EOF
  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  require 'lspconfig'.gopls.setup{
    cmd = {"/Users/jarv/go/bin/gopls", "serve"},
  }
EOF
