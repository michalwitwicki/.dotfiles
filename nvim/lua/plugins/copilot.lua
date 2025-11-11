return {
	{
		'zbirenbaum/copilot.lua',
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				yaml = true,
				markdown = true,
				help = true,
				gitcommit = true,
				gitrebase = true,
			},
		},
	},
	{
		'CopilotC-Nvim/CopilotChat.nvim',
		dependencies = {
			{'zbirenbaum/copilot.lua'},
			{'ibhagwan/fzf-lua'}, -- Use fzf-lua as a picker
			{'nvim-lua/plenary.nvim'}, -- for curl, log wrapper
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			debug = true, -- Enable debugging
			-- See Configuration section for rest
		},
		event = "VeryLazy",
		keys = {
			-- Chat about visual selection
			{
				"<leader>av",
				function()
					local input = vim.fn.input("Chat about visual selection: ")
					if input ~= "" then
						require("CopilotChat").ask(input, { selection = require("CopilotChat.select").visual })
					end
				end,
				mode = "x",
				desc = "CopilotChat - Select visual selection and ask",
			},
			-- Custom input for CopilotChat
			{
				"<leader>ai",
				function()
					local input = vim.fn.input("Ask Copilot: ")
					if input ~= "" then
						vim.cmd("CopilotChat " .. input)
					end
				end,
				desc = "CopilotChat - Ask input",
			},
			-- Quick chat with Copilot
			{
				"<leader>ab",
				function()
					local input = vim.fn.input("Chat about whole buffer: ")
					if input ~= "" then
						require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
					end
				end,
				desc = "CopilotChat - Select whole buffer and ask",
			},
			-- Use predefined prompt with whole buffer
			{
				"<leader>ap",
				function()
					require("CopilotChat").select_prompt({ selection = require("CopilotChat.select").buffer })
				end,
				desc = "CopilotChat - Use prompt with whole buffer",
			},

			{ "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
			{ "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
			{ "<leader>ap", "<cmd>CopilotChatPrompts<cr>", mode = "v", desc = "CopilotChat - Prompts" },
		},
	}
}
