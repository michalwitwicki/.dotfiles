return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
        {'williamboman/mason.nvim'},
        {'williamboman/mason-lspconfig.nvim'},
        {'neovim/nvim-lspconfig'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'hrsh7th/nvim-cmp'},
        {'L3MON4D3/LuaSnip'},
    },
    config = function()
        local lsp_zero = require('lsp-zero')

        lsp_zero.on_attach(function(client, bufnr)
            -- see :help lsp-zero-keybindings
            -- to learn the available actions
            lsp_zero.default_keymaps({buffer = bufnr})
        end)

        -- see :help lsp-zero-guide:integrate-with-mason-nvim
        -- to learn how to use mason.nvim with lsp-zero
        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = {'clangd', 'rust_analyzer', 'bashls', 'pyright', 'lua_ls', 'marksman'}, -- 'autotools-language-server'
            handlers = {
                lsp_zero.default_setup,
            }
        })

        lsp_zero.set_sign_icons({
            error = '✘',
            warn = '▲',
            hint = '⚑',
            info = '»'
        })

        -- get rid off annoying clangd warning
        local cmp_nvim_lsp = require "cmp_nvim_lsp"

        require("lspconfig").clangd.setup {
            on_attach = on_attach,
            capabilities = cmp_nvim_lsp.default_capabilities(),
            cmd = {
                "clangd",
                "--offset-encoding=utf-16",
            },
        }

        -- completion configuration
        require('lsp-zero').extend_cmp()

        local cmp = require('cmp')
        local cmp_action = require('lsp-zero').cmp_action()

        -- local has_words_before = function()
        --     if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
        --     local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        --     return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
        -- end

        cmp.setup({
            sources = {
                {name = 'copilot', group_index = 2},
                {name = 'nvim_lsp', group_index = 2},
            },
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({select = false}),
                ['<Tab>'] = cmp_action.luasnip_supertab(),
                ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
                ['<C-Space>'] = cmp.mapping.complete(),
                -- ["<Tab>"] = vim.schedule_wrap(function(fallback)
                --     if cmp.visible() and has_words_before() then
                --         cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                --     else
                --         fallback()
                --     end
                -- end),
            }),
            preselect = 'item',
            completion = {
                completeopt = 'menu,menuone,noinsert'
            },
            formatting = {
                -- changing the order of fields so the icon is the first
                fields = {'menu', 'abbr', 'kind'},

                -- here is where the change happens
                format = function(entry, item)
                    local menu_icon = {
                        nvim_lsp = 'λ',
                        luasnip = '⋗',
                        buffer = 'Ω',
                        path = '🖫',
                        nvim_lua = 'Π',
                    }

                    item.menu = menu_icon[entry.source.name]
                    return item
                end,
            },
        })
    end
}

-- K: Displays hover information about the symbol under the cursor in a floating window. See :help vim.lsp.buf.hover().
--
-- gd: Jumps to the definition of the symbol under the cursor. See :help vim.lsp.buf.definition().
--
-- gD: Jumps to the declaration of the symbol under the cursor. Some servers don't implement this feature. See :help vim.lsp.buf.declaration().
--
-- gi: Lists all the implementations for the symbol under the cursor in the quickfix window. See :help vim.lsp.buf.implementation().
--
-- go: Jumps to the definition of the type of the symbol under the cursor. See :help vim.lsp.buf.type_definition().
--
-- gr: Lists all the references to the symbol under the cursor in the quickfix window. See :help vim.lsp.buf.references().
--
-- gs: Displays signature information about the symbol under the cursor in a floating window. See :help vim.lsp.buf.signature_help(). If a mapping already exists for this key this function is not bound.
--
-- <F2>: Renames all references to the symbol under the cursor. See :help vim.lsp.buf.rename().
--
-- <F3>: Format code in current buffer. See :help vim.lsp.buf.format().
--
-- <F4>: Selects a code action available at the current cursor position. See :help vim.lsp.buf.code_action().
--
-- gl: Show diagnostics in a floating window. See :help vim.diagnostic.open_float().
--
-- [d: Move to the previous diagnostic in the current buffer. See :help vim.diagnostic.goto_prev().
--
-- ]d: Move to the next diagnostic. See :help vim.diagnostic.goto_next().
