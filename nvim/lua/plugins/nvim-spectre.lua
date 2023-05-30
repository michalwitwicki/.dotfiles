require('spectre').setup({
    color_devicons = false,
})

vim.keymap.set('n', '<leader>s', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word in every file"
})
vim.keymap.set('n', '<leader>sf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search current word in current file"
})
vim.keymap.set('v', '<leader>s', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search selected word in every file"
})
