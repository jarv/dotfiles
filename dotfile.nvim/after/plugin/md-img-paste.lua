vim.cmd([[
        autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
        let g:mdip_imgdir_absolute="/Users/jarv/src/jarv/jarv.org/static/img"
        let g:mdip_imdir_intext="/img"
]])
