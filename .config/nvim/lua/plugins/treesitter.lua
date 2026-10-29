return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"tsx",
				"typescript",
				"javascript",
				"jsdoc",
				"json",
				"html",
				"css",
				"prisma",
				"yaml",
				"markdown",
				"markdown_inline",
				"regex",
			})
			opts.highlight = vim.tbl_deep_extend("force", opts.highlight or {}, {
				enable = true,
				additional_vim_regex_highlighting = false,
			})
			opts.indent = { enable = true }
			opts.incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			}
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufReadPost",
		opts = {
			max_lines = 3,
			multiline_threshold = 1,
		},
	},
}
