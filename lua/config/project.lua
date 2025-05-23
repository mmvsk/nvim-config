dofile(vim.fn.stdpath("config") .. "/init.lua")

vim.opt.colorcolumn = "81,101"
vim.opt.cursorline = true
vim.opt.showtabline = 2 -- 2 = always show tab line
vim.opt.laststatus = 3 -- 2 = always show status line
vim.opt.cmdheight = 1 -- show small command bar

-- Auto-open NvimTree if it's the first tab
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     vim.schedule(function()
--       local ok = pcall(require, "nvim-tree.api")
--       if ok then
--         vim.cmd("NvimTreeOpen")
--         vim.cmd("wincmd p")
--       end
--     end)
--   end,
-- })
