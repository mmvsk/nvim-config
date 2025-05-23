-- ~/.config/nvim/lua/plugins
-- Base plugin list for lazy.nvim — minimal, fast, Lua-native

return {
	-- File tree (NERDTree replacement)
	{
		"nvim-tree/nvim-tree.lua",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup {
				view = { width = 30 },
				renderer = { group_empty = true },
				filters = { dotfiles = false },
				git = { enable = true },
			}
			vim.keymap.set("n", "<F4>", ":NvimTreeToggle<CR>", { silent = true })
		end,
	},

	-- Native LSP support
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lsp = require("lspconfig")
			lsp.tsserver = nil -- deprecated, replaced with ts_ls
			lsp.ts_ls.setup {}
			lsp.lua_ls.setup {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			}
		end,
	},

	-- super fast got to place (use `s<sth>`)
	-- {
	-- 	"ggandor/leap.nvim",
	-- 	config = function()
	-- 		require("leap").add_default_mappings()
	-- 	end,
	-- },

	-- modern tagbar
	{
		"stevearc/aerial.nvim",
		opts = {},
		cmd = "AerialToggle",
		keys = {
			{ "<F8>", "<cmd>AerialToggle<cr>", desc = "Toggle code outline" }
		},
	},


	-- modern replacement for vim-surround: yank, change, add quotes, ...
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = true,
	},


	-- LSP installer
	{ "williamboman/mason.nvim",           config = true },
	{ "williamboman/mason-lspconfig.nvim", config = true },

	{ "editorconfig/editorconfig-vim" },


	-- Autocompletion (like CoC but native)
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup {
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				},
			}
		end,
	},

	-- Autopairs (Lexima-style)
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local npairs = require("nvim-autopairs")
			local Rule = require("nvim-autopairs.rule")
			npairs.setup { check_ts = true }
			npairs.add_rules {
				Rule("{ ", " }")
						:with_pair(function(opts) return opts.line:sub(opts.col - 1, opts.col - 1) == "{" end)
						:with_move(function(opts) return opts.char == "}" end),
			}
		end,
	},

	-- Treesitter (for fast and accurate syntax highlighting)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup {
				ensure_installed = { "lua", "typescript", "tsx", "json", "html" },
				highlight = {
					enable = true,
					disable = function(_, buf)
						local max = 100 * 1024
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						return ok and stats and stats.size > max
					end,
				},
				indent = { enable = true },
			}
		end,
	},

	-- commenting (gcc in command, gc in select)
	{
		"numToStr/Comment.nvim",
		keys = {
			{ "gcc",        mode = "n",          desc = "Toggle comment line" },
			{ "gc",         mode = { "n", "v" }, desc = "Toggle comment block" },
			{ "<leader>cc", mode = "n",          desc = "Toggle comment line" },
			{ "<leader>c",  mode = { "n", "v" }, desc = "Toggle comment block" },
		},
		config = function()
			require("Comment").setup({
				padding = false,
			})
		end,
	},

	-- :%S:...
	{ "tpope/vim-abolish" },



	-- alignment
	{
		"junegunn/vim-easy-align",
		keys = {
			{ "ga", "<Plug>(EasyAlign)", mode = { "n", "x" } },
		},
	},

	-- show marks
	{
		"chentoast/marks.nvim",
		config = function()
			require("marks").setup {
				default_mappings = true, -- enable 'dm', 'm<space>', etc.
			}
		end,
	},

	-- not in-your-face notifs
	{
		"rcarriga/nvim-notify",
		lazy = false,
		config = function()
			local notify = require("notify")
			notify.setup {
				--background_colour = "#000000",
				timeout = 2000,
				--stages = "fade", -- or "static"
				stages = "static",
				top_down = false,
			}
			vim.notify = notify

			-- Optional filter to silence annoying reloads
			local original = vim.notify
			vim.notify = function(msg, level, opts)
				if msg:match("config change detected") then return end
				original(msg, level, opts)
			end
		end,
	},

	-- show changed lines
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup {
				signs = {
					add          = { text = "│" },
					change       = { text = "│" },
					delete       = { text = "_" },
					topdelete    = { text = "‾" },
					changedelete = { text = "~" },
				},
				on_attach = function(bufnr)
					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
					end

					map("n", "]g", require("gitsigns").next_hunk, "Next Git hunk")
					map("n", "[g", require("gitsigns").prev_hunk, "Prev Git hunk")
					map("n", "<leader>gb", require("gitsigns").blame_line, "Blame line")
					map("n", "<leader>gs", require("gitsigns").stage_hunk, "Stage hunk")
					map("n", "<leader>gu", require("gitsigns").undo_stage_hunk, "Undo stage hunk")
					map("n", "<leader>gr", require("gitsigns").reset_hunk, "Reset hunk")
				end,
			}
		end,
	},

	-- see git diff
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<CR>",        desc = "Diff against HEAD" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "File history (diffs)" },
		}
	},

	-- markdown support
	{
		"preservim/vim-markdown",
		ft = { "markdown" },
		config = function()
			vim.g.vim_markdown_new_list_item_indent = 0
			vim.g.vim_markdown_auto_insert_bullets = 1
			vim.g.vim_markdown_folding_disabled = 1

			local function toggle_checkbox()
				local row = vim.api.nvim_win_get_cursor(0)[1] - 1
				local line = vim.api.nvim_get_current_line()

				local indent = line:match("^(%s*)") or ""
				local bullet = line:match("^%s*([%-%*])") or "-"
				local rest = line:gsub("^%s*[%-%*]%s*", "")

				local new_line

				if rest:match("^%[ %]") then
					-- [ ] → [x]
					new_line = indent .. bullet .. " [x] " .. rest:sub(5)
				elseif rest:match("^%[x%]") then
					-- [x] → plain
					new_line = indent .. bullet .. " " .. rest:sub(6)
				elseif rest == "" then
					-- bare bullet → add [ ]
					new_line = indent .. bullet .. " [ ] "
				else
					-- plain → [ ]
					new_line = indent .. bullet .. " [ ] " .. rest
				end

				vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })
			end

			local function is_blank_bullet(line)
				return line:match("^%s*[%-%*]%s*$") or line:match("^%s*[%-%*]%s*%[ %]%s*$")
			end

			local function smart_indent(should_indent)
				local row = vim.api.nvim_win_get_cursor(0)[1] -- current row
				local line = vim.api.nvim_get_current_line()

				if is_blank_bullet(line) then
					vim.cmd(should_indent and "normal! >>" or "normal! <<")
					local new_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
					vim.api.nvim_win_set_cursor(0, { row, #new_line })
					vim.cmd("startinsert")
				else
					vim.api.nvim_input(should_indent and "<Tab>" or "<S-Tab>")
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					-- Toggle checkbox with <Space> on bullets
					vim.keymap.set("n", "<Space>", toggle_checkbox, { buffer = true, silent = true })

					-- Smart Tab indent/dedent
					vim.keymap.set("i", "<Tab>", function() smart_indent(true) end, { buffer = true })
					vim.keymap.set("i", "<S-Tab>", function() smart_indent(false) end, { buffer = true })
				end,
			})
		end,
	},

	{
		"dkarter/bullets.vim",
		ft = { "markdown", "text", "gitcommit" },
		config = function()
			vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
			vim.g.bullets_outline_levels = { "num", "abc", "-", "*", "+" } -- whatever you prefer
		end,
	},


	-- Theme (Gruvbox)
	{
		"morhetz/gruvbox",
		lazy = false,
		priority = 1000,
		config = function()
			--vim.cmd("colorscheme gruvbox") --
		end,
	},

	-- Theme (One)
	{
		"rakr/vim-one",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.one_allow_italics = 1
			vim.cmd("colorscheme one")
			vim.api.nvim_create_autocmd("BufWinEnter", {
				pattern = "NvimTree_*",
				callback = function()
					vim.cmd("set winhighlight=Normal:NvimTreeNormal")
					vim.cmd("highlight NvimTreeNormal guibg=#21252b")
				end,
			})

			vim.cmd([[
				highlight VertSplit guibg=NONE guifg=#282c34
				highlight WinSeparator guibg=NONE guifg=#282c34
			]])

			vim.api.nvim_create_autocmd("WinEnter", {
				callback = function()
					if vim.bo.filetype ~= "NvimTree" then
						vim.wo.winhighlight = "Normal:Normal,NormalNC:NormalNC"
					end
				end,
			})

			vim.api.nvim_create_autocmd("WinLeave", {
				callback = function()
					if vim.bo.filetype ~= "NvimTree" then
						vim.wo.winhighlight = "Normal:NormalNC,NormalNC:NormalNC"
					end
				end,
			})

			vim.api.nvim_set_hl(0, "NormalNC", { bg = "#252930" }) -- slightly darker than Normal
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local original_laststatus = vim.opt.laststatus:get()

			require("lualine").setup({
				options = {
					theme = "auto",
					globalstatus = true,
					--section_separators = { left = "", right = "" },
					--component_separators = { left = "", right = "" },
				},
				-- sections = {
				-- 	lualine_a = { "mode" },
				-- 	lualine_b = { "branch", "diff" },
				-- 	lualine_c = { "filename" },
				-- 	lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
				-- 	lualine_y = { "progress" },
				-- 	lualine_z = { "location" },
				-- },
			})

			vim.opt.laststatus = original_laststatus
		end,
	},

}
