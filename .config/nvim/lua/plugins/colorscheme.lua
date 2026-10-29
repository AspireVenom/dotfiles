return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "moon",
			on_highlights = function(hl, c)
				hl["@lsp.type.interface"] = { fg = c.green1 }
				hl["@lsp.type.enum"] = { fg = c.orange }
				hl["@lsp.type.enumMember"] = { fg = c.orange, italic = true }
				hl["@lsp.type.namespace"] = { fg = c.teal }
				hl["@lsp.type.typeParameter"] = { fg = c.yellow, italic = true }
				hl["@lsp.typemod.function.defaultLibrary"] = { fg = c.blue1 }
				hl["@lsp.typemod.variable.readonly"] = { fg = c.purple, bold = true }
			end,
		},
	},
	-- Colorscheme selection lives in theme.lua (-> current Omarchy theme's neovim.lua). Setting LazyVim's
	-- colorscheme here too made the winner depend on plugin-spec load order.
}
