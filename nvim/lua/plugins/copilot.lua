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
      -- Ask about visual selection
      {
        "<leader>av",
        function()
          local input = vim.fn.input("Ask AI <visual selection>: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { resources = "selection" })
          else
            require("CopilotChat").ask("> #selection", {})
          end
        end,
        mode = "x",
        desc = "CopilotChat - Ask about visual selection",
      },
      -- Custom input for CopilotChat
      {
        "<leader>ai",
        function()
          local input = vim.fn.input("Ask AI: ")
          if input ~= "" then
            require("CopilotChat").ask(input, {})
          end
        end,
        desc = "CopilotChat - Ask Copilot",
      },
      -- Ask about buffer
      {
        "<leader>ab",
        function()
          local input = vim.fn.input("Ask AI <buffer>: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { resources = "buffer" })
          else
            require("CopilotChat").ask("> #buffer", {})
          end
        end,
        desc = "CopilotChat - Ask about buffer",
      },
      -- Use predefined prompt with whole buffer
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt({ resources = "buffer" })
        end,
        desc = "CopilotChat - Use prompt with whole buffer",
      },
      -- Use predefined prompt with selection
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt({ resources = "selection" })
        end,
        mode = "x",
        desc = "CopilotChat - Use prompt with selection",
      },

      { "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
      { "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle side panel" },
    },
  }
}

