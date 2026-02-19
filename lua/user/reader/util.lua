--- Pager utilities: ANSI detection and follow mode

local M = {}

--- Scan first 100 lines for ANSI escape sequences.
--- Only runs for empty/text filetypes (no point re-parsing syntax-highlighted code).
--- Returns true if escapes are found.
function M.check_escape_sequences()
	local ft = vim.bo.filetype
	if ft ~= "" and ft ~= "text" then return false end
	local lines = vim.api.nvim_buf_get_lines(0, 0, math.min(100, vim.api.nvim_buf_line_count(0)), false)
	for _, line in ipairs(lines) do
		if line:find("\27%[") then return true end
	end
	return false
end

--- Toggle tail-F style follow mode.
--- When enabled, a timer scrolls to the end of the buffer every 500ms.
local follow_timer = nil

function M.toggle_follow()
	if follow_timer then
		follow_timer:stop()
		follow_timer:close()
		follow_timer = nil
		vim.notify("Follow mode OFF", vim.log.levels.INFO)
	else
		follow_timer = vim.uv.new_timer()
		follow_timer:start(0, 500, vim.schedule_wrap(function()
			if not vim.api.nvim_buf_is_valid(0) then
				if follow_timer then
					follow_timer:stop()
					follow_timer:close()
					follow_timer = nil
				end
				return
			end
			vim.cmd("silent! checktime")
			vim.cmd("normal! G")
		end))
		vim.notify("Follow mode ON", vim.log.levels.INFO)
	end
end

return M
