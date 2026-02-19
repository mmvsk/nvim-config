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
			local use_window_picker = vim.g.tree_window_picker == true
			local last_active_window = nil

			-- Only track last active window if NOT using window picker
			if not use_window_picker then
				vim.api.nvim_create_autocmd("WinLeave", {
					callback = function()
						local ft = vim.bo.filetype
						if ft ~= "NvimTree" then
							last_active_window = vim.api.nvim_get_current_win()
						end
					end,
				})
			end

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
				actions = {
					open_file = {
						window_picker = {
							enable = use_window_picker, -- Configurable via vim.g.tree_window_picker
						},
					},
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

					if use_window_picker then
						-- Use default behavior with A/B/C prompt
						vim.keymap.set("n", "o", api.node.open.edit, opts)
						vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts)
					else
						-- Custom function to open file in last active window
						local function open_in_last_active()
							local node = api.tree.get_node_under_cursor()
							if node and node.type == "file" then
								-- If we have a tracked last active window and it's valid
								if last_active_window and vim.api.nvim_win_is_valid(last_active_window) then
									vim.api.nvim_set_current_win(last_active_window)
									vim.cmd.edit(node.absolute_path)
								else
									-- Fallback: find first non-nvim-tree window
									for _, win in ipairs(vim.api.nvim_list_wins()) do
										local win_buf = vim.api.nvim_win_get_buf(win)
										local win_ft = vim.api.nvim_buf_get_option(win_buf, "filetype")
										if win_ft ~= "NvimTree" then
											vim.api.nvim_set_current_win(win)
											vim.cmd.edit(node.absolute_path)
											last_active_window = win
											return
										end
									end
									-- If no other window, just open normally
									api.node.open.edit()
								end
							elseif node and node.type == "directory" then
								-- For directories, just toggle them
								api.node.open.edit()
							end
						end

						-- Key mappings using custom open function
						vim.keymap.set("n", "o", open_in_last_active, opts)
						vim.keymap.set("n", "<2-LeftMouse>", open_in_last_active, opts)
					end

					-- Common mappings regardless of window picker setting
					vim.keymap.set("n", "C", api.tree.change_root_to_node, opts)
					vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts)
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
		lazy = false,
		priority = 1000,
		config = function()
			require("onedark").setup {
				style = "dark",
				lualine = { transparent = true },
			}

			require("onedark").load()

			-- Zen mode: dim inactive windows and cleaner UI
			if vim.g.zen_mode then
				-- Style colorcolumn as a subtle line (very slight background difference)
				vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2c313a" })

				-- Style tabline to match file tree background
				local tab_bg = "#21252b"
				vim.api.nvim_set_hl(0, "TabLineFill", { bg = tab_bg }) -- Tab bar background
				vim.api.nvim_set_hl(0, "TabLine", { fg = "#5c6370", bg = tab_bg }) -- Inactive tabs (dimmer text)
				vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#abb2bf", bg = tab_bg, bold = true }) -- Active tab (brighter text)

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
				vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = winsep_fg, bg = tree_bg })

				-- Set up window highlighting for inactive windows
				local nvimtree_hl = "Normal:NvimTreeNormal,EndOfBuffer:NvimTreeEndOfBuffer,SignColumn:NvimTreeSignColumn,WinSeparator:NvimTreeWinSeparator,VertSplit:NvimTreeWinSeparator"

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
			end
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

	-- Color highlighter (CSS/SCSS/SASS only)
	{
		"NvChad/nvim-colorizer.lua",
		ft = { "css", "scss", "sass" },
		config = function()
			require("colorizer").setup({
				filetypes = { "css", "scss", "sass" },
				user_default_options = {
					names = true,
					tailwind = false,
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
