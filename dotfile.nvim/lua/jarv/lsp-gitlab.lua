-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#add-the-configuration-to-lspconfig-recommended
-- https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/wikis/Neovim-setup-with-vim-cmp
local lspconfig = require("lspconfig")
local lsp_configurations = require('lspconfig.configs')
local settings = {
  baseUrl = "https://gitlab.com",
  token = vim.env.GITLAB_API_TOKEN_CODE_SUGGESTIONS,
}

if not lsp_configurations.gitlab_lsp then
  lsp_configurations.gitlab_lsp = {
    default_config = {
      name = "gitlab_lsp",
      cmd = { "gitlab-lsp", "--stdio" },
      filetypes = { "ruby", "go", "javascript" },
      single_file_support = true,
      root_dir = function(fname)
        return lspconfig.util.find_git_ancestor(fname)
      end,
      settings = settings,
    },
    docs = {
      description = "GitLab Code Suggestions",
    },
  }
end

require('lspconfig').gitlab_lsp.setup({})
