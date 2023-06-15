local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>ft', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fu', builtin.grep_string, {}) --grep string under cursor

require('telescope').setup{
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
        path_display = { "truncate" }
    }
}

-- preview_scrolling_up
