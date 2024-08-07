return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
		local JarvFugitive = vim.api.nvim_create_augroup("JarvFugitive", {})

		local autocmd = vim.api.nvim_create_autocmd
		autocmd("BufWinEnter", {
			group = JarvFugitive,
			pattern = "*",
			callback = function()
				if vim.bo.ft ~= "fugitive" then
					return
				end

				local bufnr = vim.api.nvim_get_current_buf()
				local opts = { buffer = bufnr, remap = false }
				vim.keymap.set("n", "<leader>p", function()
					vim.cmd.Git("push")
				end, opts)

				-- rebase always
				vim.keymap.set("n", "<leader>P", function()
					vim.cmd.Git({ "pull", "--rebase" })
				end, opts)
			end,
		})
	end,
}
-- vim: ts=2 sts=2 sw=2 et
