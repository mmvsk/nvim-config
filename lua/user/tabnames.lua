-- Rename tabs

local M = {}
local tab_names = {}

function M.set(name)
	tab_names[vim.fn.tabpagenr()] = name
	vim.cmd("redrawtabline")
end

function M.get(tabnr)
	return tab_names[tabnr]
end

function M.reset()
	tab_names = {}
end

function M.tabline()
	local s = ""
	for i = 1, vim.fn.tabpagenr("$") do
		local label = tab_names[i] or tostring(i)
		local is_active = (i == vim.fn.tabpagenr())
		s = s .. "%" .. i .. "T" -- switch to tab
		s = s .. (is_active and "%#TabLineSel#" or "%#TabLine#")
		s = s .. " " .. label .. " "
	end
	s = s .. "%#TabLineFill#%T"
	return s
end

return M
