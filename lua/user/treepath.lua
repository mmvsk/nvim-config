local M = {}

M.OpenTreeForPath = function(path)
	local tree = require("nvim-tree.api").tree
	vim.cmd("lcd " .. vim.fn.fnameescape(path)) -- for buffer-local cwd (optional)
	tree.open()
	tree.change_root(path)
	vim.cmd("wincmd p") -- go back to editor window
end

return M
