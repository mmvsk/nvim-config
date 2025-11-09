-- Git Plugins: gitsigns, diffview

return {
	-- Show git changes in gutter
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

	-- View git diffs
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<CR>",        desc = "Diff against HEAD" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "File history (diffs)" },
		}
	},
}
