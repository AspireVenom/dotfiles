-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Space Space for fuzzy find string (live grep)
vim.keymap.set("n", "<leader><leader>", function()
	local ok, builtin = pcall(require, "telescope.builtin")
	if ok then
		builtin.live_grep()
		return
	end
	local ok_snacks, snacks = pcall(require, "snacks")
	if ok_snacks and snacks and snacks.picker and snacks.picker.grep then
		snacks.picker.grep()
	else
		vim.notify("No fuzzy grep available (install telescope or snacks)", vim.log.levels.ERROR)
	end
end, { desc = "Live Grep (Telescope/Snacks)" })
