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

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				handlers = {
					ts_ls = function() end,
				},
				ensure_installed = {
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

	-- Native LSP support
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Default config for most servers
			local default_config = {
				capabilities = capabilities,
			}

			-- Configure each server
			vim.lsp.config("html", default_config)
			vim.lsp.config("cssls", default_config)
			vim.lsp.config("tailwindcss", default_config)
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			})

			vim.lsp.config("clangd", default_config)     -- c/c++
			vim.lsp.config("rust_analyzer", default_config) -- rust
			vim.lsp.config("gopls", default_config)      -- go
			vim.lsp.config("bashls", default_config)     -- bash
			vim.lsp.config("yamlls", default_config)     -- yaml
			vim.lsp.config("taplo", default_config)      -- toml; better than toml-lsp
			vim.lsp.config("zls", default_config)        -- zig
			vim.lsp.config("prismals", default_config)   -- prisma
			vim.lsp.config("dockerls", default_config)   -- docker
			vim.lsp.config("jsonls", default_config)     -- json
			vim.lsp.config("pyright", default_config)    -- python by microsoft (alt is pylsp)

			-- Enable servers
			vim.lsp.enable("html")
			vim.lsp.enable("cssls")
			vim.lsp.enable("tailwindcss")
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("clangd")
			vim.lsp.enable("rust_analyzer")
			vim.lsp.enable("gopls")
			vim.lsp.enable("bashls")
			vim.lsp.enable("yamlls")
			vim.lsp.enable("taplo")
			vim.lsp.enable("zls")
			vim.lsp.enable("prismals")
			vim.lsp.enable("dockerls")
			vim.lsp.enable("jsonls")
			vim.lsp.enable("pyright")
		end,
	},

	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("typescript-tools").setup({
				settings = {
					expose_as_code_action = {
						"add_missing_imports",
						"remove_unused",
						"organize_imports",
						"fix_all",
					},
				},
			})
		end,
	},

	{
		"nvim-treesitter/playground",
		cmd = "TSPlaygroundToggle",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},

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

	{ "editorconfig/editorconfig-vim" },


	-- Autocompletion (like CoC but native)
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
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
					{ name = "buffer" },
					{ name = "path" },
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
					additional_vim_regex_highlighting = false,
					disable = function(lang, buf)
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
		dependencies = { "nvim-cmp" },
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

	-- mdx
	{
		"davidmh/mdx.nvim",
		config = true,
		dependencies = { "nvim-treesitter/nvim-treesitter" }
	},

	-- not in-your-face notifs
	{
		"rcarriga/nvim-notify",
		lazy = false,
		config = function()
			local notify = require("notify")
			notify.setup {
				timeout = 2000,
				stages = "static",
				top_down = false,
			}
			vim.notify = notify

			-- Filter to silence annoying reloads
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


	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "onedark",
					icons_enabled = true,
					globalstatus = true,
					disabled_filetypes = {
						statusline = {
							"NvimTree",
							"neo-tree",
						},
					},
				},
			})
		end
	},

	{
		"navarasu/onedark.nvim",
		priority = 1000,
		config = function()
			require("onedark").setup {
				style = "dark",
				lualine = { transparent = true },
			}

			require("onedark").load()
		end,
	},

		-- Slim template support
	{
		"slim-template/vim-slim",
		ft = { "slim" },
	},

}
