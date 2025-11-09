-- Coding Plugins: treesitter, language-specific tools

return {
	-- Treesitter (fast and accurate syntax highlighting)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
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

			-- Ensure treesitter comment highlights link to Comment group for all languages
			-- The onedark theme (as of Nov 2025) only sets @comment, not language-specific ones
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local ft = args.match
					-- Link language-specific comment highlight to Comment
					vim.schedule(function()
						vim.api.nvim_set_hl(0, "@comment." .. ft, { link = "Comment" })
					end)
				end,
			})
		end,
	},

	-- Treesitter playground (inspect syntax tree)
	{
		"nvim-treesitter/playground",
		cmd = "TSPlaygroundToggle",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},

	-- Auto-close and auto-rename HTML/JSX/TSX tags
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require('nvim-ts-autotag').setup({
				opts = {
					enable_close = true, -- Auto close tags
					enable_rename = true, -- Auto rename pairs of tags
					enable_close_on_slash = false -- Auto close on trailing </
				}
			})
		end,
	},

	-- Code outline (modern tagbar)
	{
		"stevearc/aerial.nvim",
		opts = {},
		cmd = "AerialToggle",
		keys = {
			{ "<F8>", "<cmd>AerialToggle<cr>", desc = "Toggle code outline" }
		},
	},

	-- MDX support
	{
		"davidmh/mdx.nvim",
		ft = "mdx",
		config = true,
		dependencies = { "nvim-treesitter/nvim-treesitter" }
	},

	-- Markdown support
	{
		"mmvsk/markdown-checkbox.nvim",
		ft = "markdown",
		config = function()
			require("markdown-checkbox").setup({
				keymap = "<Space>" -- default
			})
		end
	},

	-- Slim template support
	{
		"slim-template/vim-slim",
		ft = { "slim" },
	},
}
