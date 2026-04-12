-- Rename tabs (keyed by stable tab handle, not tab number)

local M = {}
local tab_names = {}

function M.set(name)
	tab_names[vim.api.nvim_get_current_tabpage()] = name
	vim.cmd("redrawtabline")
end

function M.get(tabnr)
	local tabs = vim.api.nvim_list_tabpages()
	local handle = tabs[tabnr]
	return handle and tab_names[handle]
end

function M.reset()
	tab_names = {}
end

function M.tabline()
	local s = ""
	local tabs = vim.api.nvim_list_tabpages()
	local current = vim.api.nvim_get_current_tabpage()
	for i, handle in ipairs(tabs) do
		local label = tab_names[handle] or tostring(i)
		local is_active = (handle == current)
		s = s .. "%" .. i .. "T"
		s = s .. (is_active and "%#TabLineSel#" or "%#TabLine#")
		s = s .. " " .. label .. " "
	end
	s = s .. "%#TabLineFill#%T"
	return s
end

return M
