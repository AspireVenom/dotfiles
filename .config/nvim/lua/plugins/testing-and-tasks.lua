return {
	{
		"nvim-neotest/neotest",
		dependencies = { "marilari88/neotest-vitest" },
		opts = function(_, opts)
			opts.adapters = opts.adapters or {}
			table.insert(opts.adapters, require("neotest-vitest"))
		end,
	},
	{
		"stevearc/overseer.nvim",
		opts = {
			strategy = { "toggleterm" },
			task_list = { direction = "right" },
			templates = { "overseer.template.vscode" },
		},
		keys = {
			{ "<leader>or", function() require("overseer").run_template() end, desc = "Overseer: Run task" },
			{ "<leader>ot", function() require("overseer").toggle() end, desc = "Overseer: Task list" },
		},
	},
}


