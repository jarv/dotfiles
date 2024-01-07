local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require("lazy").setup({
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.x',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function() 
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },  
			})
		end
	},
	{ 
		"bling/vim-airline",
		lazy = false,
		priority = 500, 

	},
	{
		'rose-pine/neovim',
		lazy = false,
		priority = 1000, 
		config = function()
			vim.cmd('colorscheme rose-pine')
		end,
	},
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		lazy = true,
		config = false,
		init = function()
			-- Disable automatic setup, we are doing it manually
			vim.g.lsp_zero_extend_cmp = 0
			vim.g.lsp_zero_extend_lspconfig = 0
		end,
	},
	{
		'williamboman/mason.nvim',
		lazy = false,
		config = true,
	},

	-- Autocompletion
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			{'L3MON4D3/LuaSnip'},
		},
		config = function()
			-- Here is where you configure the autocompletion settings.
			local lsp_zero = require('lsp-zero')
			lsp_zero.extend_cmp()

			-- And you can configure cmp even more, if you want to.
			local cmp = require('cmp')
			local cmp_action = lsp_zero.cmp_action()

			cmp.setup({
				formatting = lsp_zero.cmp_format(),
				mapping = cmp.mapping.preset.insert({
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-u>'] = cmp.mapping.scroll_docs(-4),
					['<C-d>'] = cmp.mapping.scroll_docs(4),
					['<C-f>'] = cmp_action.luasnip_jump_forward(),
					['<C-b>'] = cmp_action.luasnip_jump_backward(),
				})
			})
		end
	},
	-- LSP
	-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/lazy-loading-with-lazy-nvim.md
	{
		'neovim/nvim-lspconfig',
		cmd = {'LspInfo', 'LspInstall', 'LspStart'},
		event = {'BufReadPre', 'BufNewFile'},
		dependencies = {
			{'hrsh7th/cmp-nvim-lsp'},
			{'williamboman/mason-lspconfig.nvim'},
		},
		config = function()
			-- This is where all the LSP shenanigans will live
			local lsp_zero = require('lsp-zero')
			lsp_zero.extend_lspconfig()

			lsp_zero.on_attach(function(client, bufnr)
				-- see :help lsp-zero-keybindings
				-- to learn the available actions
				lsp_zero.default_keymaps({buffer = bufnr})
			end)

			require('mason-lspconfig').setup({
				ensure_installed = {},
				handlers = {
					lsp_zero.default_setup,
					lua_ls = function()
						-- (Optional) Configure lua language server for neovim
						local lua_opts = lsp_zero.nvim_lua_ls()
						require('lspconfig').lua_ls.setup(lua_opts)
					end,
				}
			})
		end
	},
	"rust-lang/rust.vim",
	"nvim-lua/plenary.nvim",
	"lewis6991/gitsigns.nvim",
	"cakebaker/scss-syntax.vim",
	"chase/vim-ansible-yaml",
	"ervandew/supertab",
	"fatih/vim-go",
	"google/vim-jsonnet",
	"hashivim/vim-terraform",
	"shumphrey/fugitive-gitlab.vim",
	"towolf/vim-helm",

	"tpope/vim-commentary",
	"tpope/vim-fugitive",
	"tpope/vim-surround",
	"tpope/vim-sleuth",

	"vim-scripts/AnsiEsc.vim",
	"z0mbix/vim-shfmt",
	"zah/nim.vim",
	"rlue/vim-fold-rspec",
	"pedrohdz/vim-yaml-folds",
	"dfendr/clipboard-image.nvim",
	"dense-analysis/ale",
	"pangloss/vim-javascript",
	"leafgarland/typescript-vim",
	"maxmellon/vim-jsx-pretty",
	"jparise/vim-graphql",
	"laytan/cloak.nvim",
	"eandrju/cellular-automaton.nvim",
})

require("jarv.remap")
require("jarv.commands")
