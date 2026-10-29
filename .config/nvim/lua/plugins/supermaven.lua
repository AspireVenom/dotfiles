-- Supermaven inline suggestions. Base spec comes from the LazyVim extra
-- (lazyvim.json -> "lazyvim.plugins.extras.ai.supermaven"), which wires
-- <Tab> through blink.cmp's ai_accept so it doesn't fight snippet/menu <Tab>.
-- vim.g.ai_cmp = false (config/options.lua) keeps suggestions as ghost text.
return {
	{
		"supermaven-inc/supermaven-nvim",
		opts = {
			keymaps = {
				accept_word = "<C-j>", -- accept next word only
				clear_suggestion = "<C-]>",
			},
			log_level = "off",
		},
	},
}
