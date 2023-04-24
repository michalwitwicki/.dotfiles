-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
    -- Packer can manage itself
    use {'wbthomason/packer.nvim'}

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    -- Colors
    use {'ellisonleao/gruvbox.nvim'}

    -- Treesitter
    use ('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

    -- LSP Zero
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {                                      -- Optional
            'williamboman/mason.nvim',
            run = function()
                pcall(vim.cmd, 'MasonUpdate')
            end,
            },
            {'williamboman/mason-lspconfig.nvim'}, -- Optional

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},     -- Required
            {'hrsh7th/cmp-nvim-lsp'}, -- Required
            {'L3MON4D3/LuaSnip'},     -- Required
        }
    }

    -- Nvim Tree
    use {'nvim-tree/nvim-tree.lua'}

    -- Comment
    use {'numToStr/Comment.nvim'}

    -- Jump anywhere plugin
    use {'ggandor/leap.nvim'}

    -- Status line
    use {'nvim-lualine/lualine.nvim'}

    -- Git stuff
    use {'lewis6991/gitsigns.nvim'}
    use {
        'TimUntersberger/neogit',
        requires = 'nvim-lua/plenary.nvim'
    }

    -- Undo tree
    use {'mbbill/undotree'}

    -- Highlight words and lines on the cursor
    use {'yamatsum/nvim-cursorline'}
end)
