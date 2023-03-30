-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require("nvim-tree").setup({
    renderer = {
        icons = {
            glyphs = {
                folder = {
                    arrow_closed = "▶",
                    arrow_open = "▼"
                }
            },
            show = {
                file = false,
                folder = false,
                folder_arrow = true,
                git = true,
                modified = false
            }
        }
    }
})

vim.keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>")
