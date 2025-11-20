return {
	"saxon1964/neovim-tips",
	version = "*", -- Only update on tagged releases
	lazy = false,  -- Load only when keybinds are triggered
	dependencies = {
		"MunifTanjim/nui.nvim",
		-- OPTIONAL: Choose your preferred markdown renderer (or omit for raw markdown)
		-- "MeanderingProgrammer/render-markdown.nvim", -- Clean rendering
		-- OR: "OXY2DEV/markview.nvim", -- Rich rendering with advanced features
	},
	opts = {
		-- IMPORTANT: Daily tip DOES NOT WORK with lazy = true
		-- Reason: lazy = true loads plugin only when keybinds are triggered,
		--         but daily_tip needs plugin loaded at startup
		-- Solution: Keep daily_tip = 0 here, or use Option 2 below for daily tips
		daily_tip = 1,  -- 0 = off, 1 = once per day, 2 = every startup
		-- Other optional settings...
		bookmark_symbol = "🌟 ",

		-- Show footer in daily tip popup (set to false to hide)
		show_daily_tip_footer = false,
	},
	keys = {
		{ "<leader>it", ":NeovimTips<CR>", desc = "Neovim tips" },
		{ "<leader>ir", ":NeovimTipsRandom<CR>", desc = "Show random tip" },
	},
}
