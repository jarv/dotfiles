return {
	"dense-analysis/ale",
	config = function()
		vim.cmd([[
		let g:ale_linters = {
		\ 'go': ['golangci-lint'],
		\ 'markdown':      ['mdl', 'writegood'],
		\ 'jsonnet':      ['jsonnset-lint'],
		\ 'yaml':      ['yamllint'],
		\ 'sh': ['shellcheck'],
		\ 'bash': ['shellcheck'],
		\ 'javascript': ['eslint'],
		\}

		let g:ale_fixers = {
		\ 'python': ['black'],
		\ 'go': ['gofmt'],
		\ '*': ['remove_trailing_lines', 'trim_whitespace'],
		\ 'javascript': ['prettier'],
		\ 'typescript': ['prettier'],
		\}

		let g:ale_echo_msg_format = '%linter%: %s'
		let g:ale_ruby_rubocop_executable = 'bundle'
		let g:ale_ruby_rubocop_options = '-D'
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
]])
	end
}
