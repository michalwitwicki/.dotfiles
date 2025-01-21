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
        vim.keymap.set('n', '<leader>nc', ':Neorg toggle-concealer<CR>')
    end,
}

-- Default keybindings

-- All files
-- <LocalLeader>nn - create a new .norg file to take notes in

-- Norg only, insert mode
-- <C-d> - demote an object recursively
-- <C-t> - promote an object recursively
-- <M-CR> - create an iteration of e.g. a list item
-- <M-d> - insert a link to a date at the current cursor position

-- Norg only, normal mode
-- <, - demote an object non-recursively
-- << - demote an object recursively
-- <C-Space> - switch the task under the cursor between a select few states
-- <CR> - hop to the destination of the link under the cursor
-- <LocalLeader>cm - magnifies a code block to a separate buffer.
-- <LocalLeader>id - insert a link to a date at the given position
-- <LocalLeader>li - invert all items in a list
-- <LocalLeader>lt - toggle a list from ordered <-> unordered
-- <LocalLeader>ta - mark the task under the cursor as "ambiguous"
-- <LocalLeader>tc - mark the task under the cursor as "cancelled"
-- <LocalLeader>td - mark the task under the cursor as "done"
-- <LocalLeader>th - mark the task under the cursor as "on-hold"
-- <LocalLeader>ti - mark the task under the cursor as "important"
-- <LocalLeader>tp - mark the task under the cursor as "pending"
-- <LocalLeader>tr - mark the task under the cursor as "recurring"
-- <LocalLeader>tu - mark the task under the cursor as "undone"
-- <M-CR> - same as <CR>, except open the destination in a vertical split
-- >. - promote an object non-recursively
-- >> - promote an object recursively

-- Norg only, visual mode
-- < - demote objects in range
-- > - promote objects in range
