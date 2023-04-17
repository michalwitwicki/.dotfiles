vim.g.mapleader = " "

--- CTRL stuff ---

-- Save file with ctrl-s --
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<ESC>:w<CR>")

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


--- Another stuff ---

-- Escape insert mode --
vim.keymap.set("i", "jk", "<Esc>")

-- Move lines selected in visual mode --
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep search terms in the middle --
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
