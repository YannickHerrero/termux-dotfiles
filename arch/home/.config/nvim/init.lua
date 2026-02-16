-- ============== NEOVIM CONFIGURATION ==============
-- Minimal config for Termux suckless desktop
-- Plugin manager: lazy.nvim
-- Theme: Catppuccin Mocha

-- Leader keys (MUST be set before loading lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ============== OPTIONS ==============

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation (4 spaces)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Appearance
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Behavior
vim.opt.clipboard = "unnamedplus"   -- Use system clipboard (xclip)
vim.opt.mouse = "a"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- ============== BASIC KEYMAPS ==============

local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Better escape
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Move lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- ============== LOAD PLUGINS ==============

require("config.lazy")
