return {
  'nvim-tree/nvim-tree.lua',
  config = function()
    -- disable netrw at the very start of your init.lua (strongly advised)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- set termguicolors to enable highlight groups
    vim.opt.termguicolors = true

    local function my_on_attach(bufnr)
      local api = require('nvim-tree.api')

      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- copy default mappings here from defaults in next section
      vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node,          opts('CD'))
      vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer,     opts('Open: In Place'))
      ---
      -- OR use all default mappings
      api.config.mappings.default_on_attach(bufnr)

      -- add your mappings
      vim.keymap.set('n', '?', api.tree.toggle_help,      opts('Help'))
      vim.keymap.set('n', '<C-l>', api.node.open.vertical,    opts('Open: Vertical Split'))
    end

    require("nvim-tree").setup({
      on_attach = my_on_attach,
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
      },
      actions = {
        open_file = {
          resize_window = false
        }
      },
      update_focused_file = {
        enable = true
      }
    })

    vim.keymap.set("n", "<leader>e", ":lua require('nvim-tree.api').tree.toggle({find_file = true})<CR>")

    local function open_nvim_tree(data)

      -- buffer is a real file on the disk
      local real_file = vim.fn.filereadable(data.file) == 1

      -- buffer is a [No Name]
      local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

      if not real_file and not no_name then
        return
      end

      -- open the tree, find the file but don't focus it
      require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
    end

    -- vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
  end
}
