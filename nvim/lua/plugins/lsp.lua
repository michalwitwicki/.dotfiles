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



-- Keybindings
-- When a language server gets attached to a buffer you gain access to some keybindings and commands. All of these shortcuts are bound to built-in functions, so you can get more details using the :help command.
-- K: Displays hover information about the symbol under the cursor in a floating window. See :help vim.lsp.buf.hover().
-- gd: Jumps to the definition of the symbol under the cursor. See :help vim.lsp.buf.definition().
-- gD: Jumps to the declaration of the symbol under the cursor. Some servers don't implement this feature. See :help vim.lsp.buf.declaration().
-- gi: Lists all the implementations for the symbol under the cursor in the quickfix window. See :help vim.lsp.buf.implementation().
-- go: Jumps to the definition of the type of the symbol under the cursor. See :help vim.lsp.buf.type_definition().
-- gr: Lists all the references to the symbol under the cursor in the quickfix window. See :help vim.lsp.buf.references().
-- gs: Displays signature information about the symbol under the cursor in a floating window. See :help vim.lsp.buf.signature_help(). If a mapping already exists for this key this function is not bound.
-- <F2>: Renames all references to the symbol under the cursor. See :help vim.lsp.buf.rename().
-- <F3>: Format code in current buffer. See :help vim.lsp.buf.format().
-- <F4>: Selects a code action available at the current cursor position. See :help vim.lsp.buf.code_action().
-- gl: Show diagnostics in a floating window. See :help vim.diagnostic.open_float().
-- [d: Move to the previous diagnostic in the current buffer. See :help vim.diagnostic.goto_prev().
-- ]d: Move to the next diagnostic. See :help vim.diagnostic.goto_next().
