-- Editor Plugins: completion, autopairs, surround, commenting, alignment, etc.

return {
	-- Autocompletion (native fuzzy completion)
	{
		"saghen/blink.cmp",
		version = "*",   -- release tag → prebuilt fuzzy binary
		lazy = false,    -- load at startup; LSP capabilities depend on it
		opts = {
			-- Disable completion in prose / unknown buffers (ports old nvim-cmp behavior)
			enabled = function()
				return not vim.tbl_contains({ "markdown", "text", "" }, vim.bo.filetype)
			end,
			keymap = {
				preset = "enter",                          -- <CR> accepts only when an item is selected
				["<Tab>"]     = { "select_next", "fallback" },
				["<S-Tab>"]   = { "select_prev", "fallback" },
				["<C-n>"]     = { "select_next", "fallback" },
				["<C-p>"]     = { "select_prev", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			},
			completion = {
				list = { selection = { preselect = false, auto_insert = false } }, -- mirror old noselect + confirm{select=false}
				accept = { auto_brackets = { enabled = true } },
			},
			sources = { default = { "lsp", "path" } },     -- match old sources (no buffer/snippet plugin)
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
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

	-- Commenting: native gc/gcc (built-in since 0.10), with <leader>c alias
	-- Note: padding is controlled by commentstring (e.g. "// %s" = space, "//%s" = no space)

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

}
