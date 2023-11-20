vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.mouse = 'a'
vim.opt.laststatus = 3

vim.opt.jumpoptions = 'view'

vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

vim.o.splitright = true

vim.opt.list = true
vim.opt.listchars = {
    tab='▸-',
    lead='·',
    trail='·',
    -- eol = '¬'
}
