-- Editor Plugins: completion, autopairs, surround, commenting, alignment, etc.

return {
	-- Autocompletion (like CoC but native)
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
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
				-- Disable autocomplete for text-based files
				enabled = function()
					local filetype = vim.bo.filetype
					local disabled_filetypes = {
						"markdown",
						"text",
						"", -- unknown/no filetype
					}
					for _, ft in ipairs(disabled_filetypes) do
						if filetype == ft then
							return false
						end
					end
					return true
				end,
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

			-- Integrate autopairs with cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-- Autopairs (auto-close brackets, quotes, etc.)
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

	-- Surround (yank, change, delete surrounding quotes/brackets)
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = true,
	},

	-- Commenting (gcc in normal mode, gc in visual mode)
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

	-- :%S for smart case-preserving substitution
	{ "tpope/vim-abolish" },

	-- Alignment (ga in visual mode)
	{
		"junegunn/vim-easy-align",
		keys = {
			{ "ga", "<Plug>(EasyAlign)", mode = { "n", "x" } },
		},
	},

	-- Show marks in gutter
	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		config = function()
			require("marks").setup {
				default_mappings = true, -- enable 'dm', 'm<space>', etc.
			}
		end,
	},

	-- Fuzzy finder (ESSENTIAL!)
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
		},
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				defaults = {
					layout_strategy = "horizontal",
					layout_config = {
						height = 0.9,
						width = 0.9,
					},
				},
			})
		end,
	},

	-- Session management
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
		keys = {
			{ "<leader>ss", function() require("persistence").load() end, desc = "Restore Session" },
			{ "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
			{ "<leader>sd", function() require("persistence").stop() end, desc = "Don't Save Session" },
		},
	},

	-- EditorConfig support
	{ "editorconfig/editorconfig-vim" },
}
