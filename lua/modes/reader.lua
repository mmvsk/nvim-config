-- ~/.config/nvim/lua/modes/reader.lua
-- Pager mode entry point: nvim -R -u ~/.config/nvim/lua/modes/reader.lua
-- No plugins loaded — just the theme from disk and reader/pager keybindings.

-- Leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = "_"

-- Encoding & shell
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = { "utf-8", "ucs-bom", "default", "latin1" }
vim.opt.shell = "/bin/bash"

-- Performance
vim.opt.lazyredraw = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 0
vim.opt.timeout = true
vim.opt.timeoutlen = 500
vim.opt.synmaxcol = 300
vim.opt.redrawtime = 1500

-- Disable all persistence
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false
vim.opt.shadafile = "NONE"

-- UI: reader/pager-specific
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.list = false
vim.opt.showtabline = 0
vim.opt.laststatus = 0
vim.opt.cmdheight = 1
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.shortmess:append("cIF")
vim.opt.scrolloff = 4
vim.opt.wrap = false
vim.opt.linebreak = true  -- applies when wrap is toggled on
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = false
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.sidescrolloff = 4
vim.opt.fillchars = { eob = " " }
vim.opt.clipboard = "unnamedplus"

-- Load onedark directly from lazy's install path (no plugin manager)
local theme_path = vim.fn.stdpath("data") .. "/lazy/onedark.nvim"
if vim.loop.fs_stat(theme_path) then
	vim.opt.rtp:prepend(theme_path)
	local ok, onedark = pcall(require, "onedark")
	if ok then
		onedark.setup({ style = "dark" })
		onedark.load()
	end
end

-- Add config dir to rtp so require("reader.*") works
local this_file = debug.getinfo(1, "S").source:sub(2) -- strip leading @
local config_dir = vim.fn.fnamemodify(this_file, ":h:h:h") -- up from lua/modes/reader.lua
vim.opt.rtp:prepend(config_dir)

-- Pager keymaps
local map = vim.keymap.set
local opts = { silent = true, noremap = true }

map("n", "q", ":qa!<CR>", opts)
map("n", "<Space>", "<C-f>", opts)
map("n", "<S-Space>", "<C-b>", opts)
map("n", "d", "<C-d>", opts)
map("n", "u", "<C-u>", opts)
map("n", "g", "gg", opts)
map("n", "G", "G", opts)
map("n", "F", function() require("user.reader.util").toggle_follow() end, opts)
map("n", "w", ":set wrap!<CR>", opts)
-- /  ?  n  N are native vim search — no mapping needed
map("n", "<leader>y", ":%y+<CR>", { silent = true, desc = "Yank entire buffer" })
map("n", "<leader>q", ":q<CR>", opts)
map("n", "<leader>Q", ":qa<CR>", opts)
map("n", "<leader><space>", ":nohlsearch<CR>", opts)

-- Splits
map("n", "<leader>-", "<C-w>s", opts)
map("n", "<leader>\\", "<C-w>v", opts)
map("n", "<C-j>", "<C-W>j", opts)
map("n", "<C-k>", "<C-W>k", opts)
map("n", "<C-h>", "<C-W>h", opts)
map("n", "<C-l>", "<C-W>l", opts)

-- j/k stay as normal vim movement
-- Less-style scroll bindings (uncomment to switch):
-- map("n", "j", "<C-e>", opts)
-- map("n", "k", "<C-y>", opts)

-- Make j/k move by display lines when wrapped
map("n", "j", [[v:count == 0 ? 'gj' : 'j']], { expr = true, silent = true })
map("n", "k", [[v:count == 0 ? 'gk' : 'k']], { expr = true, silent = true })

-- Horizontal scrolling with Alt + MouseScroll (useful in no-wrap mode)
map("n", "<A-ScrollWheelUp>", "5zh", opts)
map("n", "<A-ScrollWheelDown>", "5zl", opts)

-- Autocmd: process buffer on enter
vim.api.nvim_create_autocmd({ "VimEnter", "BufWinEnter" }, {
	callback = function()
		-- Check for ANSI escapes and apply highlights
		local util = require("user.reader.util")
		if util.check_escape_sequences() then
			require("user.reader.ansi").run()
		end

		-- Lock the buffer
		vim.bo.modifiable = false
		vim.bo.readonly = true
		vim.bo.buftype = "nofile"
	end,
})

-- Cleanup tmpfile on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		local tmpfile = vim.env.NVIM_PAGER_TMPFILE
		if tmpfile and tmpfile ~= "" then
			os.remove(tmpfile)
		end
	end,
})
