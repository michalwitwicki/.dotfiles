return {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    config = function()
        require("neorg").setup {
            load = {
                ["core.defaults"] = {},
                ["core.concealer"] = {},
                ["core.dirman"] = {
                    config = {
                        workspaces = {
                            notes = "~/repos/notes",
                        },
                        default_workspace = "notes",
                    },
                },
            },
        }

        vim.wo.foldlevel = 99
        vim.wo.conceallevel = 2

        vim.keymap.set('n', '<leader>nn', '<Plug>(neorg.dirman.new-note)')
        vim.keymap.set('n', '<leader>ns', ':vnew<CR>:Neorg index<CR>')
        vim.keymap.set('n', '<leader>nt', ':tabnew<CR>:Neorg index<CR>')
        vim.keymap.set('n', '<leader>nr', ':Neorg return<CR>')
    end,
}
