vim.g.mapleader = " "

--- CTRL stuff ---

-- Save file with ctrl-s --
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<ESC>:w<CR>")
vim.keymap.set("v", "<C-s>", "<ESC>:w<CR>gv")

-- Keep cursor in the middle while half-page jumping --
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Easily exit vertical edit mode --
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Close buffer --
vim.keymap.set("n", "<C-c>", ":q<CR>")


--- Leader stuff ---

-- Add empty lines above or below current one --
vim.keymap.set("n", "<leader>O", "O<Esc>j")
vim.keymap.set("n", "<leader>o", "o<Esc>k")

-- Paste over without loosing current paste buffer --
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Delete into void register --
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- Yank into system clipboard --
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Resize split windows --
vim.keymap.set("n", "<leader><Up>", ":resize +5<CR>")
vim.keymap.set("n", "<leader><Down>", ":resize -5<CR>")
vim.keymap.set("n", "<leader><Right>", ":vertical resize +5<CR>")
vim.keymap.set("n", "<leader><Left>", ":vertical resize -5<CR>")

-- Open new tmux window with vim config directory and reload config on exit --
vim.keymap.set("n", "<leader>,", ":silent !tmux new-window -n 'vim_config' 'cd $HOME/.config/nvim && nvim'<CR>:source $MYVIMRC<CR>")

--- Another stuff ---

-- Escape insert mode --
vim.keymap.set("i", "jk", "<Esc>")

-- Move lines selected in visual mode --
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep search terms in the middle --
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


--- Custom functions ---
function Set_normal_settings()
    print("--- Normal settings enabled ---")
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
    vim.opt.textwidth = 0
end

function Set_kernel_settings()
    print("--- Kernel settings enabled ---")
    vim.opt.tabstop = 8
    vim.opt.softtabstop = 8
    vim.opt.shiftwidth = 8
    vim.opt.expandtab = false
    vim.opt.textwidth = 80
end

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter" }, {
    pattern = {"/*/drivers/*"},
    callback = function()
        Set_kernel_settings()
    end
})

vim.keymap.set('n', '<leader>gn', Set_normal_settings, {})
vim.keymap.set('n', '<leader>gk', Set_kernel_settings, {})
