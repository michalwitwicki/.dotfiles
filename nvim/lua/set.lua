vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = false
vim.opt.smarttab = true
vim.opt.shiftround = true

vim.opt.fileencoding = "UTF-8"
vim.g.editorconfig = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.mouse = 'a'

vim.opt.jumpoptions = 'view'

vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.helpheight = 30

vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=o]] })
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions+=r]] })
-- - "o" -- O and o, don't continue comments
-- + "r" -- But do continue when pressing enter.

vim.opt.list = true
vim.opt.listchars = {
  tab='▸-',
  lead='·',
  trail='·',
  -- eol = '¬'
}

-- Map <leader>tw to toggle display of invisible characters
vim.api.nvim_set_keymap('n', '<leader>tw', ':set list!<CR>', {noremap = true, silent = true})

-- Map <leader>tl to toggle Line wrapping
vim.api.nvim_set_keymap('n', '<leader>tl', ':set wrap!<CR>', {noremap = true, silent = true})

--- Custom functions ---
-- run with ":lua Print_tab_settings()"
function Print_tab_settings()
  local bufnr = vim.api.nvim_get_current_buf()
  print("--- Current TAB settings ---")
  print("tabstop: " .. vim.api.nvim_buf_get_option(bufnr, 'tabstop'))
  print("shiftwidth: " .. vim.api.nvim_buf_get_option(bufnr, 'shiftwidth'))
  print("softtabstop: " .. vim.api.nvim_buf_get_option(bufnr, 'softtabstop'))
  print("expandtab: " .. tostring(vim.api.nvim_buf_get_option(bufnr, 'expandtab')))
  print("autoindent: " .. tostring(vim.api.nvim_buf_get_option(bufnr, 'autoindent')))
  print("smartindent: " .. tostring(vim.api.nvim_buf_get_option(bufnr, 'smartindent')))
  print("smarttab: " .. tostring(vim.api.nvim_get_option('smarttab')))
  print("shiftround: " .. tostring(vim.api.nvim_get_option('shiftround')))
  print("fileencoding: " .. vim.api.nvim_buf_get_option(bufnr, 'fileencoding'))
  print("--- Applied editorconfig properties ---")
  vim.print(vim.b.editorconfig)
end

-- Quick explanation of the tab options:
-- tabstop (8): Number of spaces that a <tab> in the file counts for.
-- shiftwidth (8): Number of spaces to use for each step of (auto)indent.
-- softtabstop (0): Answers the question: how many columns of whitespace is a <tab> or <backspace> keypress worth. If -1 then value of shiftwidth is used.
-- expandtab (off): If on, <tab> keypress is converted to spaces.
-- autoindent (on): If on, copy indent from current line when starting a new line.
-- smartindent (off): If on, automatically inserts indent for example after a line ending in "{". Autoindent should also be on when using smartindent
-- smarttab (on): If on, <tab> keypress is converted to spaces according to shiftwidth. If off, <tab> inserts blanks according to tabstop.
-- shiftround (off): If on, indent to the nearest multiple of shiftwidth.

-- Prefered kernel settings:
-- vim.opt.tabstop = 8
-- vim.opt.softtabstop = 8
-- vim.opt.shiftwidth = 8
-- vim.opt.expandtab = false

-- Function to toggle colorcolumn
function _G.toggle_colorcolumn()
  if vim.wo.colorcolumn == "" then
    vim.wo.colorcolumn = "80"
  else
    vim.wo.colorcolumn = ""
  end
end

-- Map <leader>tc to toggle colorcolumn
vim.api.nvim_set_keymap('n', '<leader>tc', ':lua toggle_colorcolumn()<CR>', {noremap = true, silent = true})

-- "boxes" utility mappings
vim.keymap.set('n', '<leader>bb', '!!boxes -a c -s 60 -d simple<CR>', { noremap = true, silent = false, desc = "Draw big box with boxes utility" })
vim.keymap.set('v', '<leader>bb', '!boxes -a c -s 60 -d simple<CR>', { noremap = true, silent = false, desc = "Draw big box with boxes utility" })
vim.keymap.set('n', '<leader>bd', '!!boxes -d javadoc<CR>', { noremap = true, silent = false, desc = "Draw doxygen comment" })


function surround_line_with_equals(total_length)
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local text = vim.trim(line)
  local text_len = #text
  if total_length <= text_len + 2 then
    total_length = text_len + 4
  end
  local padding = total_length - text_len - 2
  local left = math.floor(padding / 2)
  local right = padding - left
  local new_line = string.rep("=", left) .. " " .. text .. " " .. string.rep("=", right)
  vim.api.nvim_set_current_line(new_line)
end

vim.keymap.set('n', '<leader>bs', ':lua surround_line_with_equals(60)<CR>')

