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
				disable_netrw = true,
				hijack_netrw = true,
				respect_buf_cwd = true,
				sync_root_with_cwd = true,
				-- NOT WORKING
				--sync_root_with_cwd = false, -- disable auto-sync to global cwd
				--respect_buf_cwd = true, -- use buffer-local cwd (so it respects lcd)
				--update_cwd = true, -- update tree root when cwd changes
				view = {
					width = 30,
					side = "left",
					signcolumn = "yes",
					number = false,
					relativenumber = false,
				},
				renderer = {
					group_empty = true,
					indent_markers = {
						enable = true,
					},
					icons = {
						show = {
							file = false,
							folder = false,
							folder_arrow = true,
							git = true,
						},
					},
				},
				filters = {
					dotfiles = false,
					custom = {
						"^.git$",   -- hide the `.git` directory
						"^node_modules$", -- hide `node_modules`
					},
				},
				sort = {
					sorter = "case_sensitive"
				},
				git = {
					enable = true,
					ignore = false,
				},
				on_attach = function(bufnr)
					local api = require("nvim-tree.api")
					local opts = { buffer = bufnr, noremap = true, silent = true }

					-- Key mappings
					vim.keymap.set("n", "o", api.node.open.edit, opts)
					vim.keymap.set("n", "C", api.tree.change_root_to_node, opts)
					vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts)

					-- Mouse mappings
					vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts)
					vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts)
				end,
			}
			vim.keymap.set("n", "<F4>", ":NvimTreeToggle<CR>", { silent = true })
		end,
	},

	-- Native LSP support
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			--"hrsh7th/cmp-nvim-lsp", -- for autocompletion
		},
		config = function()
			local lsp = require("lspconfig")
			--local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Common LSP setup with capabilities
			local function setup(server)
				lsp[server].setup({
					--capabilities = capabilities,
				})
			end

			lsp.tsserver = nil -- deprecated, replaced with ts_ls

			--setup("ts_ls")  -- or typescript-tools for faster
			lsp.ts_ls.setup {
				init_options = {
					preferences = {
						experimentalTsGo = true,
					},
				},
			}

			setup("html")
			setup("cssls")
			setup("tailwindcss")
			--lsp.tailwdind.setup {}
			lsp.lua_ls.setup {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			}

			setup("clangd")     -- c/c++
			setup("rust_analyzer") -- rust
			setup("gopls")      -- go
			setup("bashls")     -- bash
			setup("yamlls")     -- yaml
			setup("taplo")      -- toml; better than toml-lsp
			setup("zls")        -- zig
			setup("prismals")   -- prisma
			setup("dockerls")   -- docker
			setup("jsonls")     -- json
			setup("pyright")    -- python by microsoft (alt is pylsp)
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
	{
		"williamboman/mason.nvim",
		config = true,
		build = ":MasonUpdate",
	},
	{
		"williamboman/mason-lspconfig.nvim",
		--config = true,
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				-- List of servers you want installed by default
				ensure_installed = {
					"ts_ls",
					"html",
					"cssls",
					"tailwindcss",

					"clangd",
					"rust_analyzer",
					"gopls",
					"bashls",
					"yamlls",
					"taplo",
					"zls",
					"prismals",
					"dockerls",
					"jsonls",
					"pyright",

					"lua_ls",
				},
			})
		end,
	},

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

			npairs.setup {
				check_ts = true,
				enable_check_bracket_line = false, -- don't check brackets on current line
			}

			-- Add space between brackets for specific pairs
			npairs.add_rules({
				Rule(' ', ' ')
						:with_pair(function(opts)
							local pair = opts.line:sub(opts.col - 1, opts.col)
							return vim.tbl_contains({ '()', '[]', '{}' }, pair)
						end),
			})
		end,
	},

	-- Treesitter (for fast and accurate syntax highlighting)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup {
				ensure_installed = {
					"typescript",
					"javascript",
					"tsx",
					"html",
					"css",
					"scss",
					"c",
					"cpp",
					"rust",
					"go",
					"bash",
					"make",
					"zig",
					"yaml",
					"toml",
					"json",
					"json5",
					"jsonc",
					"prisma",
					"dockerfile",
					"markdown",
					"markdown_inline",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"regex",
					"comment",
				},
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false, -- Cleaner setup
					--custom_captures = {
					--	-- Customize markdown highlights
					--	["text.uri"] = { underline = false },
					--	["text.reference"] = { underline = false }
					--},
					disable = function(lang, buf)
						-- blue list dashes, flickering link underline, so disable
						--if lang == "markdown" or lang == "markdown_inline" then
						--	return true
						--end

						local max = 100 * 1024
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						return ok and stats and stats.size > max
					end,
				},
				indent = {
					enable = true,
				},
			}
		end,
	},
	-- Optional: Tailwind CSS colorizer
	{
		"roobert/tailwindcss-colorizer-cmp.nvim",
		config = true,
		after = "nvim-cmp",
	},

	-- Optional: Better Tailwind CSS integration
	{
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				user_default_options = {
					tailwind = true,
				},
			})
		end,
	},

	-- commenting (gcc in command, gc in select)
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = function()
			require("Comment").setup({
				padding = false,
			})

			local api = require("Comment.api")

			-- Comment line (normal mode)
			vim.keymap.set("n", "<leader>c", api.toggle.linewise.current, { desc = "Comment line" })

			-- Comment selection (visual)
			vim.keymap.set("v", "<leader>c", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
				{ desc = "Comment selection", silent = true })
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
		"gabrielelana/vim-markdown",
		ft = "markdown",
		init = function()
			vim.g.markdown_enable_conceal = 0
			vim.g.markdown_enable_spell_checking = 0
			vim.g.markdown_enable_input_abbreviations = 0
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.bo.tabstop = 4
					vim.bo.shiftwidth = 4
					vim.bo.softtabstop = 4
					vim.bo.expandtab = true -- optional: use spaces instead of tabs
				end,
			})
		end
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

			local BG_ACTIVE    = "#282c34"
			local BG_INACTIVE  = "#252930"
			local BG_TREE      = "#21252b"
			local GUTTER_FG    = "#555b62"
			local BORDER_COLOR = "#282c34"

			-- Active window
			vim.api.nvim_set_hl(0, "Normal", { bg = BG_ACTIVE })
			vim.api.nvim_set_hl(0, "LineNr", { fg = GUTTER_FG, bg = BG_ACTIVE })
			vim.api.nvim_set_hl(0, "SignColumn", { bg = BG_ACTIVE })
			vim.api.nvim_set_hl(0, "VertSplit", { fg = BORDER_COLOR, bg = BG_ACTIVE })
			vim.api.nvim_set_hl(0, "WinSeparator", { fg = BORDER_COLOR, bg = BG_ACTIVE })

			-- Inactive window
			vim.api.nvim_set_hl(0, "NormalNC", { bg = BG_INACTIVE })
			vim.api.nvim_set_hl(0, "LineNrNC", { fg = GUTTER_FG, bg = BG_INACTIVE })
			vim.api.nvim_set_hl(0, "SignColumnNC", { bg = BG_INACTIVE })
			vim.api.nvim_set_hl(0, "VertSplitNC", { fg = BORDER_COLOR, bg = BG_INACTIVE })
			vim.api.nvim_set_hl(0, "WinSeparatorNC", { fg = BORDER_COLOR, bg = BG_INACTIVE })

			-- NvimTree static color
			vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = BG_TREE })
			vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = BG_TREE })
			vim.api.nvim_set_hl(0, "NvimTreeVertSplit", { fg = BG_TREE, bg = BG_TREE })
			vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = BG_TREE }) -- <--- Corrected NvimTreeSignColumn
			vim.api.nvim_set_hl(0, "TabLine", { bg = BG_TREE, fg = GUTTER_FG })
			vim.api.nvim_set_hl(0, "TabLineFill", { bg = BG_INACTIVE })

			-- Apply highlight per window dynamically
			local function apply_winhighlight()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					local ft = vim.api.nvim_buf_get_option(buf, "filetype")

					if ft == "NvimTree" then
						vim.api.nvim_win_set_option(win, "winhighlight",
							"Normal:NvimTreeNormal,EndOfBuffer:NvimTreeEndOfBuffer,WinSeparator:NvimTreeVertSplit,VertSplit:NvimTreeVertSplit,SignColumn:NvimTreeSignColumn") -- <--- Added SignColumn to NvimTree winhighlight
					else
						local is_current = (win == vim.api.nvim_get_current_win())
						local hl = table.concat({
							"Normal:" .. (is_current and "Normal" or "NormalNC"),
							"SignColumn:" .. (is_current and "SignColumn" or "SignColumnNC"),
							"LineNr:" .. (is_current and "LineNr" or "LineNrNC"),
							"WinSeparator:" .. (is_current and "WinSeparator" or "WinSeparatorNC"),
							"VertSplit:" .. (is_current and "VertSplit" or "VertSplitNC"),
						}, ",")
						vim.api.nvim_win_set_option(win, "winhighlight", hl)
					end
				end
			end

			vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave", "BufWinEnter", "VimEnter" }, {
				callback = function()
					vim.defer_fn(apply_winhighlight, 10)
				end,
			})
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons", -- optional, for file icons
			"linrongbin16/lsp-progress.nvim", -- optional, for LSP progress in statusline
		},
		config = function()
			-- Customize lualine sections
			local function lsp_progress()
				local progress = require("lsp-progress")
				progress.setup()
				return progress.progress()
			end

			require("lualine").setup({
				options = {
					--theme = "auto",
					--component_separators = { left = "|", right = "|" },
					--section_separators = { left = "", right = "" },
					--disabled_filetypes = {
					--	statusline = { "dashboard", "alpha", "starter" },
					--},
					globalstatus = true, -- single statusline for all windows
				},
				--sections = {
				--	lualine_a = { "mode" },
				--	lualine_b = { "branch", "diff", "diagnostics" },
				--	lualine_c = { "filename" },
				--	lualine_x = { lsp_progress, "encoding", "fileformat", "filetype" },
				--	lualine_y = { "progress" },
				--	lualine_z = { "location" },
				--},
				--inactive_sections = {
				--	lualine_a = {},
				--	lualine_b = {},
				--	lualine_c = { "filename" },
				--	lualine_x = { "location" },
				--	lualine_y = {},
				--	lualine_z = {},
				--},
				--extensions = { "neo-tree", "toggleterm", "quickfix" },
			})
		end,
	},

	--{
	--	"navarasu/onedark.nvim",
	--	priority = 1000, -- make sure to load this before all the other start plugins
	--	config = function()
	--		require('onedark').setup {
	--			style = 'dark' -- dark, darker, cool, deep, warm, warmer
	--		}
	--		-- Enable theme
	--		require('onedark').load()
	--	end
	--},

}
