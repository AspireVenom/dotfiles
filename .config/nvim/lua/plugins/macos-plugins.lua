return {
	-- File explorer (nvim-tree) - alternative to LazyVim's neo-tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "NvimTreeToggle", "NvimTreeFocus" },
		keys = {
			{ "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree: Toggle" },
			{ "<leader>ef", "<cmd>NvimTreeFindFileToggle<cr>", desc = "NvimTree: Toggle (current file)" },
		},
		opts = {
			view = {
				width = 30,
				relativenumber = true,
			},
			renderer = {
				group_empty = true,
				indent_markers = {
					enable = true,
				},
			},
			filters = {
				dotfiles = false,
			},
			git = {
				ignore = false,
			},
		},
	},

	-- LazyGit integration
	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},

	-- Substitute operator
	{
		"gbprod/substitute.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "s", function() require("substitute").operator() end, desc = "Substitute" },
			{ "ss", function() require("substitute").line() end, desc = "Substitute line" },
			{ "S", function() require("substitute").eol() end, desc = "Substitute to end of line" },
			{ "s", function() require("substitute").visual() end, mode = "x", desc = "Substitute visual" },
		},
	},

	-- Vim matchup (enhanced % matching)
	{
		"andymass/vim-matchup",
		event = "VeryLazy",
		init = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},

	-- Tmux navigation
	{
		"christoomey/vim-tmux-navigator",
		event = "VeryLazy",
		keys = {
			{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Tmux: Navigate Left" },
			{ "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Tmux: Navigate Down" },
			{ "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Tmux: Navigate Up" },
			{ "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Tmux: Navigate Right" },
		},
	},

	-- Rainbow delimiters
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "VeryLazy",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")
			require("rainbow-delimiters.setup").setup({
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
				},
			})
		end,
	},

	-- GitHub theme (in addition to bamboo)
	{
		"projekt0n/github-nvim-theme",
		lazy = true,
		priority = 1000,
	},

	-- nvim-cmp (if you prefer it over LazyVim's blink.cmp)
	-- Uncomment to use nvim-cmp instead of blink.cmp
	-- {
	-- 	"hrsh7th/nvim-cmp",
	-- 	event = "InsertEnter",
	-- 	dependencies = {
	-- 		"hrsh7th/cmp-nvim-lsp",
	-- 		"hrsh7th/cmp-buffer",
	-- 		"hrsh7th/cmp-path",
	-- 		"L3MON4D3/LuaSnip",
	-- 		"saadparwaiz1/cmp_luasnip",
	-- 		"rafamadriz/friendly-snippets",
	-- 		"onsails/lspkind.nvim",
	-- 	},
	-- 	config = function()
	-- 		local cmp = require("cmp")
	-- 		local luasnip = require("luasnip")
	-- 		local lspkind = require("lspkind")
	--
	-- 		require("luasnip.loaders.from_vscode").lazy_load()
	--
	-- 		cmp.setup({
	-- 			snippet = {
	-- 				expand = function(args)
	-- 					luasnip.lsp_expand(args.body)
	-- 				end,
	-- 			},
	-- 			mapping = cmp.mapping.preset.insert({
	-- 				["<C-k>"] = cmp.mapping.select_prev_item(),
	-- 				["<C-j>"] = cmp.mapping.select_next_item(),
	-- 				["<C-b>"] = cmp.mapping.scroll_docs(-4),
	-- 				["<C-f>"] = cmp.mapping.scroll_docs(4),
	-- 				["<C-Space>"] = cmp.mapping.complete(),
	-- 				["<C-e>"] = cmp.mapping.abort(),
	-- 				["<CR>"] = cmp.mapping.confirm({ select = false }),
	-- 			}),
	-- 			sources = cmp.config.sources({
	-- 				{ name = "nvim_lsp" },
	-- 				{ name = "luasnip" },
	-- 				{ name = "buffer" },
	-- 				{ name = "path" },
	-- 			}),
	-- 			formatting = {
	-- 				format = lspkind.cmp_format({
	-- 					mode = "symbol_text",
	-- 					maxwidth = 50,
	-- 					ellipsis_char = "...",
	-- 				}),
	-- 			},
	-- 		})
	-- 	end,
	-- },

	-- Disable neo-tree if you prefer nvim-tree
	-- Uncomment to disable neo-tree:
	-- { "nvim-neo-tree/neo-tree.nvim", enabled = false },

	-- Disable blink.cmp if you prefer nvim-cmp
	-- Uncomment if using nvim-cmp above:
	-- { "saghen/blink.cmp", enabled = false },
}

