-- Coding Plugins: treesitter, language-specific tools

return {
	-- Treesitter: parsers, queries, and features
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		dependencies = { "RRethy/nvim-treesitter-endwise" },
		config = function()
			-- Register parsers not in nvim-treesitter's default registry.
			-- nvim-treesitter's install path reloads the parsers module (clears
			-- package.loaded and re-requires), so a plain mutation gets wiped.
			-- Also register a package.preload returning the SAME (extended) table
			-- so every re-require keeps our additions.
			local ts_parsers = require("nvim-treesitter.parsers")
			ts_parsers.d2 = {
				install_info = {
					url = "https://github.com/ravsii/tree-sitter-d2",
					revision = "main",
					queries = "queries",
				},
				tier = 3,
			}
			package.preload["nvim-treesitter.parsers"] = function() return ts_parsers end

			require("nvim-treesitter").install {
				"typescript", "javascript", "tsx", "html", "css", "scss",
				"c", "cpp", "rust", "go", "bash", "make", "zig",
				"yaml", "toml", "json", "json5", "prisma", "dockerfile",
				"lua", "vim", "vimdoc", "query", "regex", "comment", "sql", "python",
				"d2", "mermaid",
				"elixir", "heex", "eex",
			}

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf = args.buf
					-- Skip large files
					local max = 100 * 1024
					local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max then return end
					-- Enable treesitter highlighting (no-op if no parser)
					if not pcall(vim.treesitter.start, buf) then return end
					-- Enable treesitter indentation (skip markdown)
					if args.match ~= "markdown" then
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- Ensure treesitter comment highlights link to Comment group for all languages
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					vim.schedule(function()
						vim.api.nvim_set_hl(0, "@comment." .. args.match, { link = "Comment" })
					end)
				end,
			})
		end,
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
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		init = function()
			vim.filetype.add({ extension = { mdx = "mdx" } })
		end,
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

	-- D2 diagram language (terrastruct/d2)
	-- Provides ftdetect, syntax fallback, :D2Fmt, :D2Preview*, validation.
	-- Treesitter highlighting is provided by ravsii/tree-sitter-d2 (registered above).
	{
		"terrastruct/d2-vim",
		ft = { "d2" },
		init = function()
			-- Format on save is on by default (g:d2_fmt_autosave = 1) -- keep it.
			-- Don't auto-open ASCII preview pane on save -- use :D2Preview manually.
			vim.g.d2_ascii_autorender = 0
		end,
	},
}
