--- Image viewer via chafa
--- Uses nvim_open_term so the built-in terminal emulator handles ANSI colors
--- natively — no highlight groups, no E849 risk.

local api = vim.api
local font_ratio = "0.4" -- w/h
local group = api.nvim_create_augroup("ImageViewer", { clear = true })

local extensions = {}
for _, ext in ipairs({
	"png", "jpg", "jpeg", "gif", "bmp", "webp",
	"tiff", "svg", "ico", "avif", "heic", "jxl",
}) do
	table.insert(extensions, "*." .. ext)
	table.insert(extensions, "*." .. ext:upper())
end

local function render(buf)
	local path = vim.b[buf].image_path
	local chan = vim.b[buf].image_chan
	if not path or not chan then return end
	local win = vim.fn.bufwinid(buf)
	if win == -1 then return end
	local width = api.nvim_win_get_width(win)
	local height = api.nvim_win_get_height(win)

	local output = vim.fn.system({
		"chafa", "--format=symbols", "--symbols=legacy",
		"--font-ratio=" .. font_ratio,
		"--size=" .. width .. "x" .. height, path,
	})

	api.nvim_chan_send(chan, "\27[2J\27[H" .. output)
end

api.nvim_create_autocmd("BufReadCmd", {
	group = group,
	pattern = extensions,
	callback = function(ev)
		if vim.fn.executable("chafa") ~= 1 then
			vim.notify("chafa is not installed", vim.log.levels.WARN)
			return
		end
		local buf = ev.buf
		vim.b[buf].image_path = api.nvim_buf_get_name(buf)
		vim.bo[buf].bufhidden = "wipe"

		vim.b[buf].image_chan = api.nvim_open_term(buf, {})
		render(buf)

		vim.keymap.set("n", "q", "<cmd>bwipeout<cr>", { buffer = buf })
		vim.keymap.set("n", "r", function() render(buf) end, { buffer = buf })
	end,
})

api.nvim_create_autocmd("WinResized", {
	group = group,
	callback = function()
		for _, win in ipairs(vim.v.event.windows) do
			local buf = api.nvim_win_get_buf(win)
			if vim.b[buf].image_path then
				vim.schedule(function()
					if api.nvim_buf_is_valid(buf) then
						render(buf)
					end
				end)
			end
		end
	end,
})
