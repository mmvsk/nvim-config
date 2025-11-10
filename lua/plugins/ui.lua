-- UI Plugins: file tree, statusline, themes, notifications
-- Skip on servers or when vim.g.minimal_mode is set

if vim.g.minimal_mode then
	return {}
end

return {
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
		version = "v0.1.0", -- Pin to v0.1.0 until comment highlighting is fixed in v1.0.0+
		lazy = false,
		priority = 1000,
		config = function()
			require("onedark").setup {
				style = "dark",
				lualine = { transparent = true },
			}

			require("onedark").load()

			-- Style colorcolumn as a subtle line (very slight background difference)
			vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2c313a" })

			-- Dim inactive windows
			-- Active window bg: #282c34, File tree bg: #21252b
			-- Using #262a31 (slightly darker than active)
			local inactive_bg = "#262a31"
			--local inactive_bg = "#23272e"

			-- Get foreground colors to preserve them
			local linenr_fg = vim.api.nvim_get_hl(0, { name = "LineNr" }).fg
			local winsep_fg = vim.api.nvim_get_hl(0, { name = "WinSeparator" }).fg
			if not winsep_fg then
				winsep_fg = vim.api.nvim_get_hl(0, { name = "VertSplit" }).fg
			end

			-- Define highlight groups for inactive windows
			vim.api.nvim_set_hl(0, "InactiveWindow", { bg = inactive_bg })
			vim.api.nvim_set_hl(0, "InactiveLineNr", { fg = linenr_fg, bg = inactive_bg })
			vim.api.nvim_set_hl(0, "InactiveEndOfBuffer", { fg = inactive_bg, bg = inactive_bg }) -- Hide tildes
			vim.api.nvim_set_hl(0, "InactiveCursorLine", { bg = inactive_bg }) -- Hide cursorline
			vim.api.nvim_set_hl(0, "InactiveCursorColumn", { bg = inactive_bg }) -- Hide cursorcolumn
			vim.api.nvim_set_hl(0, "InactiveColorColumn", { bg = inactive_bg }) -- Hide colorcolumn

			-- Set all window separators to use inactive background
			vim.api.nvim_set_hl(0, "WinSeparator", { fg = winsep_fg, bg = inactive_bg })
			vim.api.nvim_set_hl(0, "VertSplit", { fg = winsep_fg, bg = inactive_bg })

			-- Keep NvimTree darker background for all areas
			local tree_bg = "#21252b"
			vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = tree_bg })
			vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { fg = tree_bg, bg = tree_bg })
			vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = tree_bg })

			-- Set up window highlighting for inactive windows
			local nvimtree_hl = "Normal:NvimTreeNormal,EndOfBuffer:NvimTreeEndOfBuffer,SignColumn:NvimTreeSignColumn"

			vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
				callback = function()
					if vim.bo.filetype == "NvimTree" then
						vim.wo.winhighlight = nvimtree_hl
					else
						vim.wo.winhighlight = ""
					end
				end,
			})

			vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
				callback = function()
					if vim.bo.filetype == "NvimTree" then
						vim.wo.winhighlight = nvimtree_hl
					else
						vim.wo.winhighlight = "Normal:InactiveWindow,NormalNC:InactiveWindow,SignColumn:InactiveWindow,LineNr:InactiveLineNr,CursorLineNr:InactiveLineNr,FoldColumn:InactiveWindow,EndOfBuffer:InactiveEndOfBuffer,CursorLine:InactiveCursorLine,CursorColumn:InactiveCursorColumn,ColorColumn:InactiveColorColumn"
					end
				end,
			})
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
				if msg:match("nvim%-lspconfig.*deprecated") then return end
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
