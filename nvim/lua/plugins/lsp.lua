local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({buffer = bufnr})
end)

-- lsp.setup_servers({
-- lsp.ensure_installed({
--    'lua_ls'
--    'ccls',
--    'pyright'
--    'robotframework_ls'
--})

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()


-- My overwrites --
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({select = false}),
        ['<Tab>'] = cmp_action.luasnip_supertab(),
        ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
    },
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
    }
})


local function set_new_root()
    local client = vim.lsp.get_active_clients({name = 'clangd'})[1]
    vim.lsp.stop_client(client.id)

    require('lsp-zero').use('clangd', {
      root_dir = require('lspconfig.util').root_pattern('multi_repo_project_root.txt')
    })
end

vim.keymap.set('n', '<leader>r', set_new_root, {})
