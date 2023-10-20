local builtin = require('telescope.builtin')
local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fhf', "<cmd>Telescope find_files hidden=true<cr>", {})
-- vim.keymap.set('n', '<leader>fs', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>ft', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fu', builtin.grep_string, {}) --grep string under cursor

telescope.setup {
    defaults = {
        mappings = {
            i = {
                ["<C-c>"] = "close",
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
                ["<C-l>"] = "select_vertical"
            },
            n = {
                ["<C-c>"] = "close",
                ["<C-l>"] = "select_vertical"
            }
        },
        path_display = { "truncate" } -- ,
        -- file_ignore_patterns = { "%.out" }
    },
    extensions = {
        live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = { -- extend mappings
            i = {
                ["<C-e>"] = lga_actions.quote_prompt({ postfix = " --fixed-strings " }) --search exact match
            }
        }
    }
}
}

-- Extensions start
require("telescope").load_extension("live_grep_args")
vim.keymap.set("n", "<leader>fs", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
-- Extensions end
