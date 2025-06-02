-- ~/.config/nvim/init.lua
-- Entry point — sets leader, loads lazy.nvim, and config modules

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
vim.opt.timeoutlen = 800
vim.opt.updatetime = 500
vim.opt.history = 1000
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
--vim.opt.undofile = true
vim.opt.undofile = false

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
--vim.opt.colorcolumn = "81,101"
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
--vim.opt.laststatus = 0 -- statusline (airline/lualine): 0 no show, 2 = different per split, 3 = one for all splits
--vim.opt.cmdheight = 0 -- do not even show the command bar (1 would show)
vim.opt.laststatus = 0 -- statusline (airline/lualine): 0 no show, 2 = different per split, 3 = one for all splits
vim.opt.cmdheight = 1  -- do not even show the command bar (1 would show)

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


-- show error on hover
vim.o.updatetime = 380 -- 0.5s of idle before `CursorHold` fires
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, {
			focusable = true, -- allow interaction with its text
			border = "rounded",
			source = "if_many", -- if_many or always
			prefix = "", -- ???
			scope = "cursor",
		})
	end,
})

-- JSONC & TS fixes
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "tsconfig.json", "tsconfig.*.json" },
	command = "set filetype=jsonc"
})
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
	command = "syntax sync fromstart"
})
vim.api.nvim_create_autocmd("BufLeave", {
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
	command = "syntax sync clear"
})

-- rename tabs
--vim.o.showtabline = 2
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

map("n", "<F1>", "081l?\\s\\+<CR>cw<CR><esc>", { silent = true })
map("n", "<F2>", ":set wrap!<CR>:set linebreak!<CR>", { silent = true })


-- yank full buf
map("n", "<leader>y", ":%y+<CR>", { silent = true, desc = "Yank entire buffer" })


-- Format substitutions for 2, 4, 8 spaces to tabs — visual and normal mode
vim.cmd([[
  vnoremap <leader>f  :s/  /\t/ge<CR>:'<,'>s/'/"/ge<CR>
  nnoremap <leader>f  :s/  /\t/ge<CR>:s/'/"/ge<CR>
  vnoremap <leader>2f :s/  /\t/ge<CR>:'<,'>s/'/"/ge<CR>
  nnoremap <leader>2f :s/  /\t/ge<CR>:s/'/"/ge<CR>
  vnoremap <leader>4f :s/    /\t/ge<CR>:'<,'>s/'/"/ge<CR>
  nnoremap <leader>4f :s/    /\t/ge<CR>:s/'/"/ge<CR>
  vnoremap <leader>8f :s/        /\t/ge<CR>:'<,'>s/'/"/ge<CR>
  nnoremap <leader>8f :s/        /\t/ge<CR>:s/'/"/ge<CR>
]])
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
