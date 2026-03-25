-- Markdown code block indent: use tabs in fenced code blocks, spaces elsewhere
-- Controlled by vim.g.markdown_code_block_indent (set in init.lua)

local last_code_block_state = nil

local function in_code_block()
	local ok, node = pcall(vim.treesitter.get_node)
	if not ok or not node then return false end
	while node do
		local t = node:type()
		if t == "fenced_code_block" or t == "code_fence_content" then
			return true
		end
		node = node:parent()
	end
	return false
end

local function update_md_indent()
	if not vim.g.markdown_code_block_indent then return end

	local is_code = in_code_block()
	if is_code == last_code_block_state then return end
	last_code_block_state = is_code

	if is_code then
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	else
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		last_code_block_state = nil
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.expandtab = true
		vim.opt_local.autoindent = true
		vim.opt_local.smartindent = false
		vim.opt_local.indentexpr = ""
		vim.opt_local.copyindent = true
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "InsertEnter", "InsertLeave" }, {
	callback = function()
		if vim.bo.filetype ~= "markdown" then return end
		last_code_block_state = nil
		update_md_indent()
	end,
})
