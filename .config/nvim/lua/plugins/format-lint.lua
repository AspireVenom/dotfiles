return {
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				json = { "prettierd" },
				jsonc = { "prettierd" },
				markdown = { "prettierd" },
				html = { "prettierd" },
				css = { "prettierd" },
				scss = { "prettierd" },
				yaml = { "prettierd" },
				graphql = { "prettierd" },
				prisma = { "prettierd" },
			})
			opts.format_on_save = {
				timeout_ms = 3000,
				lsp_format = "fallback",
			}
		end,
	},
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
			},
		},
	},
}
