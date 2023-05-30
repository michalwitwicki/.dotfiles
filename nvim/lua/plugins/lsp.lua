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


-- Change root of LSP to path where given file is.
-- Usefull in case of multi repo projects.
-- To use ":lua Lsp_set_multi_repo_project_root_dir()"
function Lsp_set_multi_repo_project_root_dir()
    local client = vim.lsp.get_active_clients({name = 'clangd'})[1]
    vim.lsp.stop_client(client.id)

    require('lsp-zero').use('clangd', {
      root_dir = require('lspconfig.util').root_pattern('multi_repo_project_root.txt')
    })
end

-- Example of keybinding it
-- vim.keymap.set('n', '<leader>r', Lsp_set_multi_repo_project_root_dir, {})
