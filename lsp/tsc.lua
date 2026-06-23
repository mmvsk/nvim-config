-- Native TypeScript LSP: tsc 7+ (the Go compiler) via the hidden
-- `--lsp --stdio` protocol. tsc is enabled unconditionally; `root_dir`
-- decides per project whether to attach: it declines (Deno project, or no
-- native tsc >= 7 resolvable) by returning without calling on_dir, so cmd
-- only ever runs with a confirmed native tsc. Per root, a local
-- node_modules tsc (>= 7) is preferred, falling back to the global on PATH.
local tsc = require("lsp_tsc")

-- Roots already warned about (no native tsc), so we notify at most once each.
local warned = {}

---@type vim.lsp.Config
return {
	cmd = function(dispatchers, config)
		local cmd = tsc.resolve((config or {}).root_dir)
		return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
	end,
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = function(bufnr, on_dir)
		local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
		root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } }
			or vim.list_extend(root_markers, { ".git" })
		local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
		local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })
		local project_root = vim.fs.root(bufnr, root_markers)
		-- Bail out in Deno projects so denols can attach instead.
		if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
			return
		end
		if deno_root and (not project_root or #deno_root >= #project_root) then
			return
		end
		local root = project_root or vim.fn.getcwd()
		-- Gate on a resolvable native tsc (>= 7) for this root; if none, decline
		-- (don't call on_dir) and warn once per root instead of starting a server.
		if not tsc.resolve(root) then
			if not warned[root] then
				warned[root] = true
				vim.notify(
					"No TypeScript >= 7 (tsc) found -- install `typescript@7+` locally or globally",
					vim.log.levels.WARN
				)
			end
			return
		end
		on_dir(root)
	end,
	settings = {
		typescript = {
			inlayHints = {
				parameterNames = {
					enabled = "literals",
					suppressWhenArgumentMatchesName = true,
				},
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
		},
	},
}
