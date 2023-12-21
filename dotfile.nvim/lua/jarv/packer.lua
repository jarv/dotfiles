-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {
	  'nvim-treesitter/nvim-treesitter',
	  run = function()
		  local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
		  ts_update()
	  end,}
  use("nvim-treesitter/nvim-treesitter-context");

  use({
	  'rose-pine/neovim',
	  as = 'rose-pine',
	  config = function()
		  vim.cmd('colorscheme rose-pine')
	  end
  })
  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v1.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }
  use("rust-lang/rust.vim")
  use("nvim-lua/plenary.nvim")
  use("lewis6991/gitsigns.nvim")
  use("bling/vim-airline")
  use("cakebaker/scss-syntax.vim")
  use("chase/vim-ansible-yaml")
  use("ervandew/supertab")
  use("fatih/vim-go")
  use("google/vim-jsonnet")
  use("hashivim/vim-terraform")
  use("rlue/vim-fold-rspec")
  use("shumphrey/fugitive-gitlab.vim")
  use("towolf/vim-helm")

  use("tpope/vim-commentary")
  use("tpope/vim-fugitive")
  use("tpope/vim-surround")
  use("tpope/vim-sleuth")

  use("vim-scripts/AnsiEsc.vim")
  use("z0mbix/vim-shfmt")
  use("zah/nim.vim")
  use("pedrohdz/vim-yaml-folds")
  use("ferrine/md-img-paste.vim")
  use("dense-analysis/ale")
  use("pangloss/vim-javascript")
  use("leafgarland/typescript-vim")
  use("maxmellon/vim-jsx-pretty")
  use("jparise/vim-graphql")
  use("laytan/cloak.nvim")
  use("eandrju/cellular-automaton.nvim")
end)
