return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
        {'nvim-lua/plenary.nvim'},
        {'nvim-telescope/telescope-live-grep-args.nvim'}
    },
    config = function()
        local builtin = require('telescope.builtin')
        local telescope = require('telescope')
        local lga_actions = require('telescope-live-grep-args.actions')

        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fhf', "<cmd>Telescope find_files hidden=true<cr>", {}) -- find hidden files
        -- vim.keymap.set('n', '<leader>fs', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', "<cmd>Telescope buffers hidden=true sort_lastused=true sort_mru=true<cr>", {})
        vim.keymap.set('n', '<leader>ft', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>fu', builtin.grep_string, {}) -- grep string under cursor
        vim.keymap.set('n', '<leader>fp', builtin.resume, {}) -- resume previous picker in exact state
        vim.keymap.set('n', '<leader>fm', builtin.marks, {})
        vim.keymap.set('n', '<leader>fr', builtin.registers, {})
        vim.keymap.set('n', '<leader>fj', "<cmd>Telescope jumplist fname_width=200<cr>", {})

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
                        ["<C-e>"] = lga_actions.quote_prompt({ postfix = " --fixed-strings " }) -- search exact match
                    }
                }
            }
        }
        }

        -- Extensions start
        require("telescope").load_extension("live_grep_args")
        vim.keymap.set("n", "<leader>fs", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
        -- Extensions end


        -- Custom function to search selected text in visual mode
        local getVisualSelection = function()
            vim.cmd('noau normal! "vy"')
            local text = vim.fn.getreg('v')
            vim.fn.setreg('v', {})

            text = string.gsub(text, "\n", "")
            if #text > 0 then
                return text
            else
                return ''
            end
        end

        vim.keymap.set('v', '<leader>fs', function()
            local text = getVisualSelection()
            builtin.live_grep({ default_text = text })
        end)
    end
}
