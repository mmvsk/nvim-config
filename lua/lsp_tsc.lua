-- Native TypeScript (tsc 7+, the Go compiler) resolution.
-- Only a tsc whose major version is >= 7 speaks the hidden `--lsp --stdio`
-- protocol; a TS<=6 `tsc` (the old JS compiler) breaks on it, so every
-- candidate is version-gated before use.

local M = {}

local function major_at_least_7(version)
	local major = tonumber((version or ""):match("^(%d+)"))
	return major ~= nil and major >= 7
end

-- Local tsc: read <root>/node_modules/typescript/package.json (no spawn).
local function local_native_tsc(root_dir)
	if not root_dir then
		return nil
	end
	local bin = vim.fs.joinpath(root_dir, "node_modules/.bin", "tsc")
	if vim.fn.executable(bin) ~= 1 then
		return nil
	end
	local pkg = vim.fs.joinpath(root_dir, "node_modules/typescript/package.json")
	local ok, data = pcall(vim.fn.readfile, pkg)
	if not ok or vim.tbl_isempty(data) then
		return nil
	end
	local decoded = vim.json.decode(table.concat(data, "\n"))
	return major_at_least_7(decoded and decoded.version) and bin or nil
end

-- Global tsc: resolve via PATH and parse `tsc --version` (one spawn).
local function global_native_tsc()
	if vim.fn.executable("tsc") ~= 1 then
		return nil
	end
	local out = vim.fn.system({ "tsc", "--version" })
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return major_at_least_7(out:match("(%d[%d.]*)")) and "tsc" or nil
end

-- Resolve a native tsc (>= 7) for a project root: local bin upgrade first,
-- then the global tsc on PATH. Pass nil root_dir to check the global only.
-- Returns the command (path or "tsc") or nil when none qualifies.
function M.resolve(root_dir)
	return local_native_tsc(root_dir) or global_native_tsc()
end

return M
