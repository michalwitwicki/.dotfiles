return {
	'ibhagwan/fzf-lua',
	event = "VeryLazy",
	keys = {
		{ "<leader>fc",  function() require("fzf-lua").commands() end,        desc = "search commands" },
		{ "<leader>fC",  function() require("fzf-lua").command_history() end, desc = "search command history" },
		{ "<leader>ff",  function() require("fzf-lua").files() end,           desc = "search old files" },
		{ "<leader>fh",  function() require("fzf-lua").highlights() end,      desc = "search highlights" },
		{ "<leader>fm",  function() require("fzf-lua").marks() end,           desc = "search marks" },
		{ "<leader>fM",  function() require("fzf-lua").manpages() end,        desc = "search manpages" },
		{ "<leader>fk",  function() require("fzf-lua").keymaps() end,         desc = "search keymaps" },
		{ "<leader>fs",  function() require("fzf-lua").live_grep() end,       desc = "live grep" },
		{ "<leader>fs",  function() require("fzf-lua").grep_visual() end, mode = "v", desc = "visual grep" },
		{ "<leader>fgf", function() require("fzf-lua").git_files() end,       desc = "search git file names" },
		{ "<leader>fgb", function() require("fzf-lua").git_branches() end,    desc = "search git branches" },
		{ "<leader>fgc", function() require("fzf-lua").git_commits() end,     desc = "search git commits" },
		{ "<leader>fgC", function() require("fzf-lua").git_bcommits() end,    desc = "search git buffer commits" },
		{ "<leader>fp",  function() require("fzf-lua").resume() end,          desc = "resume fzf" },
		{ "<leader>fu",  function() require("fzf-lua").grep_cword() end,      desc = "search word under cursor" },
		{ "<leader>fU",  function() require("fzf-lua").grep_cWORD() end,      desc = "search WORD under cursor" },
		{ "<leader>fj",  function() require("fzf-lua").jumps() end,           desc = "search jumps" },
		{ "<leader>fr",  function() require("fzf-lua").registers() end,       desc = "search registers" },
		{ "<leader>fh",  function() require("fzf-lua").search_history() end,  desc = "search history" },
		{ "<leader>fb",  function() require("fzf-lua").buffers() end,         desc = "search buffers" },
	},
	config = function()
		require('fzf-lua').register_ui_select()
	end
}
