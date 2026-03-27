--- Image viewer via chafa
--- Uses nvim_open_term so the built-in terminal emulator handles ANSI colors
--- natively — no highlight groups, no E849 risk.

local api = vim.api
local font_ratio = "0.4" -- w/h
local max_width = 0   -- 0 = no cap
local max_height = 0  -- 0 = no cap
local group = api.nvim_create_augroup("ImageViewer", { clear = true })

local extensions = {}
for _, ext in ipairs({
	"png", "jpg", "jpeg", "gif", "bmp", "webp",
	"tiff", "avif", "heic", "jxl",
	--"svg", "ico",
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
	local w = api.nvim_win_get_width(win)
	local h = api.nvim_win_get_height(win)
	if max_width > 0 then w = math.min(w, max_width) end
	if max_height > 0 then h = math.min(h, max_height) end

	local output = vim.fn.system({
		"chafa", "--format=symbols", "--symbols=legacy",
		"--font-ratio=" .. font_ratio,
		"--size=" .. w .. "x" .. h, path,
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

		local win = vim.fn.bufwinid(buf)
		if win ~= -1 then
			vim.wo[win].number = false
			vim.wo[win].relativenumber = false
			vim.wo[win].signcolumn = "no"
			vim.wo[win].foldcolumn = "0"
		end

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
