-- ~/.config/nvim/init.lua
-- Entry point — sets leader, loads lazy.nvim, and config modules

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = "_"

-- Environment detection
vim.g.is_root = vim.env.USER == "root" or vim.env.SUDO_USER ~= nil
vim.g.is_server = vim.fn.hostname():match("server") ~= nil or vim.fn.hostname():match("vps") ~= nil
vim.g.minimal_mode = vim.g.is_server or false -- Set to true to skip UI plugins

-- Root user safety: disable persistent files
if vim.g.is_root then
	vim.notify("Running as root - disabling persistent files", vim.log.levels.WARN)
	vim.opt.swapfile = false
	vim.opt.backup = false
	vim.opt.writebackup = false
	vim.opt.undofile = false
	vim.opt.shadafile = "NONE" -- Don't save command history
end

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
vim.opt.timeoutlen = 500  -- Wait time for key sequence completion
vim.opt.history = 1000

-- File handling (unless root user, which disables these above)
if not vim.g.is_root then
	vim.opt.swapfile = false
	vim.opt.backup = false
	vim.opt.writebackup = false
	vim.opt.undofile = true
	vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
end

-- Additional performance tweaks
vim.opt.synmaxcol = 300  -- Don't syntax highlight super long lines
vim.opt.redrawtime = 1500  -- Time in ms for redrawing the screen

-- UI
vim.opt.mouse = "a"
vim.opt.mousehide = true
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = false
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4
vim.opt.signcolumn = "yes"
vim.opt.list = true
vim.opt.listchars = {
	tab = "┊ ",
	trail = "⋅",
	extends = "▸",
	precedes = "◂",
}
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.showmode = true
vim.opt.showcmd = true
vim.opt.shortmess:append("cI") -- I = suppress intro msg
vim.opt.wildignore = { "**/node_modules/**", "**/.git/**" }
vim.opt.wildmenu = true
vim.opt.showtabline = 1 -- tabline: 0 no show, 1 = show if more than 1 tab, 2 = always show
vim.opt.laststatus = 0 -- statusline (airline/lualine): 0 no show, 2 = different per split, 3 = one for all splits
vim.opt.cmdheight = 1

-- Search
vim.opt.ignorecase = false
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.wrapscan = false

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 0
vim.opt.expandtab = false
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.smartindent = true
vim.opt.preserveindent = true
vim.opt.shiftround = true

-- Markdown-specific settings (4 spaces, expanded)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.expandtab = true
	end,
})

-- Completion
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }

-- Clipboard
vim.opt.clipboard = vim.fn.has("unnamedplus") == 1 and "unnamed,unnamedplus" or "unnamed"

-- Restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local pos = vim.fn.line([['"]])
		if pos > 1 and pos <= vim.fn.line("$") then
			vim.cmd("normal! g'\"")
		end
	end
})

-- Make j/k and arrows move by display lines (wrapped) unless a count is given
vim.keymap.set('n', 'j',  [[v:count == 0 ? 'gj' : 'j']], { expr = true, silent = true })
vim.keymap.set('n', 'k',  [[v:count == 0 ? 'gk' : 'k']], { expr = true, silent = true })
vim.keymap.set('n', '<Down>', [[v:count == 0 ? 'gj' : 'j']], { expr = true, silent = true })
vim.keymap.set('n', '<Up>',   [[v:count == 0 ? 'gk' : 'k']], { expr = true, silent = true })

-- Optional: Apply to visual/operator-pending modes too
vim.keymap.set('v', 'j',  [[v:count == 0 ? 'gj' : 'j']], { expr = true, silent = true })
vim.keymap.set('v', 'k',  [[v:count == 0 ? 'gk' : 'k']], { expr = true, silent = true })
vim.keymap.set('v', '<Down>', [[v:count == 0 ? 'gj' : 'j']], { expr = true, silent = true })
vim.keymap.set('v', '<Up>',   [[v:count == 0 ? 'gk' : 'k']], { expr = true, silent = true })

-- Show diagnostics on hover (manual with gl or <leader>d, automatic is too slow)
vim.o.updatetime = 300
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- JSONC filetype fix
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "tsconfig.json", "tsconfig.*.json" },
	command = "set filetype=jsonc"
})

-- JS/TS syntax sync (only on BufRead, not every BufEnter to avoid lag)
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
	command = "syntax sync fromstart"
})

-- rename tabs
vim.o.tabline = "%!v:lua.require'user.tabnames'.tabline()"
vim.api.nvim_create_user_command("TabRename", function(opts)
	require("user.tabnames").set(opts.args)
end, { nargs = 1 })
vim.api.nvim_create_user_command("TabooRename", function(opts)
	require("user.tabnames").set(opts.args)
end, { nargs = 1 })

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>", { silent = true })
map("n", "<leader>q", ":q<CR>", { silent = true })
map("n", "<leader>Q", ":qa<CR>", { silent = true })
map("n", "<leader>-", "<C-w>s")
map("n", "<leader>\\", "<C-w>v")
map("n", "<C-s>", ":w<CR>", { silent = true })
map("i", "<C-s>", "<Esc>:w<CR>a", { silent = true })
map("n", "<leader><space>", ":nohlsearch<CR>", { silent = true })

-- Navigation & splits
map("n", "<C-j>", "<C-W>j")
map("n", "<C-k>", "<C-W>k")
map("n", "<C-h>", "<C-W>h")
map("n", "<C-l>", "<C-W>l")

-- Tabs
map("n", "<leader>t", ":tabnew<CR>", { silent = true })
map("n", "<leader>T", ":tabclose<CR>", { silent = true })

-- Buffers
map("n", "<M-k>", ":bprevious<CR>", { silent = true })
map("n", "<M-j>", ":bnext<CR>", { silent = true })
map("n", "<F6>", ":b#<CR>", { silent = true })

-- indent selected keep selected
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Wrap current line at 80 chars at the last space (useful for markdown paragraphs)
map("n", "<F1>", "081l?\\s\\+<CR>cw<CR><esc>", { silent = true })
map("n", "<F2>", ":set wrap!<CR>:set linebreak!<CR>", { silent = true })


-- yank full buf
map("n", "<leader>y", ":%y+<CR>", { silent = true, desc = "Yank entire buffer" })


-- Format substitutions for 2, 4, 8 spaces to tabs — visual and normal mode
map("v", "<leader>f", ":s/  /\\t/ge<CR>:'<,'>s/'/\"/ge<CR>", { silent = true })
map("n", "<leader>f", ":s/  /\\t/ge<CR>:s/'/\"/ge<CR>", { silent = true })
map("v", "<leader>2f", ":s/  /\\t/ge<CR>:'<,'>s/'/\"/ge<CR>", { silent = true })
map("n", "<leader>2f", ":s/  /\\t/ge<CR>:s/'/\"/ge<CR>", { silent = true })
map("v", "<leader>4f", ":s/    /\\t/ge<CR>:'<,'>s/'/\"/ge<CR>", { silent = true })
map("n", "<leader>4f", ":s/    /\\t/ge<CR>:s/'/\"/ge<CR>", { silent = true })
map("v", "<leader>8f", ":s/        /\\t/ge<CR>:'<,'>s/'/\"/ge<CR>", { silent = true })
map("n", "<leader>8f", ":s/        /\\t/ge<CR>:s/'/\"/ge<CR>", { silent = true })
-- Global LSP formatter
map("n", "<leader>F", ":lua vim.lsp.buf.format { async = true }<CR>", { silent = true })


local original_laststatus = vim.opt.laststatus:get()

-- Load lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")


vim.opt.laststatus = original_laststatus
