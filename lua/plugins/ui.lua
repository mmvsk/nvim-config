-- UI Plugins: file tree, statusline, themes, notifications
-- Skip on servers or when vim.g.minimal_mode is set

if vim.g.minimal_mode then
	return {}
end

return {
	-- Devicons (lazy load to prevent SIXEL probe at startup)
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},

	-- File tree (NERDTree replacement)
	{
		"nvim-tree/nvim-tree.lua",
		cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen" },
		keys = { { "<F4>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" } },
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
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "BufReadPost",  -- Load after first buffer is read, not on VeryLazy
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

	-- Theme
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

	-- Notifications
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			local notify = require("notify")
			notify.setup {
				timeout = 2000,
				stages = "static",
				top_down = false,
			}
			vim.notify = notify

			-- Filter to silence annoying messages
			local original = vim.notify
			vim.notify = function(msg, level, opts)
				if msg:match("config change detected") then return end
				if msg:match("SIXEL") then return end
				original(msg, level, opts)
			end
		end,
	},

	-- Color highlighter (Tailwind CSS colors, etc)
	{
		"NvChad/nvim-colorizer.lua",
		event = "BufReadPost",  -- Load later to avoid startup probe
		config = function()
			require("colorizer").setup({
				user_default_options = {
					tailwind = true,
				},
			})
		end,
	},

	-- Tailwind CSS colorizer for completion menu
	{
		"roobert/tailwindcss-colorizer-cmp.nvim",
		lazy = true,  -- Only load when needed
		config = true,
		dependencies = { "nvim-cmp" },
	},
}
