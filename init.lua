-- ~/.config/nvim/init.lua
-- Entry point — sets leader, loads lazy.nvim, and config modules

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = "_"

-- Zen mode: enables dimmed inactive windows and cleaner UI
-- Set to true to enable, false to disable
vim.g.zen_mode = true

-- File tree window picker: enables A/B/C/... window selector when opening files
-- Set to true for keyboard-only workflow (shows A/B/C prompt)
-- Set to false for mouse workflow (opens in last active window)
vim.g.tree_window_picker = false

-- Filter annoying messages early (before plugins load)
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
	if type(msg) == "string" then
		if msg:match("nvim%-lspconfig.*deprecated") or msg:match("nvim%-lspconfig.*0%.10") then
			return
		end
	end
	original_notify(msg, level, opts)
end

-- Environment detection
vim.g.is_root = vim.env.USER == "root" or vim.env.SUDO_USER ~= nil
vim.g.is_server = vim.fn.hostname():match("server") ~= nil or vim.fn.hostname():match("vps") ~= nil
vim.g.minimal_mode = vim.g.is_server or false -- Set to true to skip UI plugins

-- Root user safety: disable persistent files
if vim.g.is_root then
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

-- Zen mode: Hide window separators and tildes
if vim.g.zen_mode then
	vim.opt.fillchars = {
		vert = " ",
		vertleft = " ",
		vertright = " ",
		horiz = " ",
		horizup = " ",
		horizdown = " ",
		verthoriz = " ",
		eob = " ",
	}
end

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

-- Markdown code block indent: use tabs in fenced code blocks, spaces elsewhere
vim.g.markdown_code_block_indent = true

do
	local last_code_block_state = nil

	local function in_code_block()
		local ok, node = pcall(vim.treesitter.get_node)
		if not ok or not node then return false end
		while node do
			local t = node:type()
			if t == "fenced_code_block" or t == "code_fence_content" then
				return true
			end
			node = node:parent()
		end
		return false
	end

	local function update_md_indent()
		if not vim.g.markdown_code_block_indent then return end

		local is_code = in_code_block()
		if is_code == last_code_block_state then return end  -- debounce: skip if no change
		last_code_block_state = is_code

		if is_code then
			vim.opt_local.expandtab = false
			vim.opt_local.tabstop = 2
			vim.opt_local.shiftwidth = 2
			vim.opt_local.softtabstop = 2
		else
			vim.opt_local.expandtab = true
			vim.opt_local.tabstop = 4
			vim.opt_local.shiftwidth = 4
			vim.opt_local.softtabstop = 4
		end
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		callback = function()
			last_code_block_state = nil  -- reset state for new buffer
			vim.opt_local.tabstop = 4
			vim.opt_local.shiftwidth = 4
			vim.opt_local.softtabstop = 4
			vim.opt_local.expandtab = true
			vim.opt_local.autoindent = true
			vim.opt_local.smartindent = false
			vim.opt_local.indentexpr = ""
			vim.opt_local.copyindent = true
		end,
	})

	vim.api.nvim_create_autocmd({ "BufEnter", "InsertEnter", "InsertLeave" }, {
		callback = function()
			if vim.bo.filetype ~= "markdown" then return end
			last_code_block_state = nil  -- reset to force re-evaluation
			update_md_indent()
		end,
	})
end

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

-- Default empty buffers to markdown (for quick notes)
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if vim.fn.bufname() == "" and vim.bo.filetype == "" and vim.bo.buftype == "" then
			vim.b.auto_markdown = true
			vim.bo.filetype = "markdown"
			-- Force-load treesitter (lazy-loaded on BufReadPost, won't fire for unnamed bufs)
			pcall(function() require("lazy").load({ plugins = { "nvim-treesitter" } }) end)
			pcall(vim.treesitter.start, 0, "markdown")
		end
	end
})

-- Re-detect filetype when saving a previously unnamed markdown buffer
-- (e.g. empty scratch → save as .txt → should become text, not stay markdown)
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		if vim.b.auto_markdown then
			vim.b.auto_markdown = nil
			vim.filetype.match({ buf = 0, filename = vim.fn.expand("%:t") })
			local detected = vim.filetype.match({ buf = 0, filename = vim.api.nvim_buf_get_name(0) })
			if detected and detected ~= "" then
				vim.bo.filetype = detected
			end
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

-- Bun shebang → typescript
vim.filetype.add({
	pattern = {
		[".*"] = {
			priority = -math.huge,
			function(_, bufnr)
				local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
				if line:find("^#!/usr/bin/env bun") then
					return "typescript"
				end
			end,
		},
	},
})

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

-- Horizontal scrolling with Alt + MouseScroll
map("n", "<A-ScrollWheelUp>", "5zh", { silent = true })
map("n", "<A-ScrollWheelDown>", "5zl", { silent = true })
map("i", "<A-ScrollWheelUp>", "<C-o>5zh", { silent = true })
map("i", "<A-ScrollWheelDown>", "<C-o>5zl", { silent = true })

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
