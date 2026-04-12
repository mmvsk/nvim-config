-- LSP Configuration: Language servers, Mason installer

local lsp_disabled = vim.env.NVIM_LSP_DISABLE == "1"

if lsp_disabled then
	return {}
end

local config = require("config")

-- TypeScript server detection (cached — result computed once per session)
-- tsgo (native Go binary) and tsserver (Node-based) are mutually exclusive:
--   tsgo detected → configured via native vim.lsp.config (upstream nvim-lspconfig settings)
--   tsserver detected → configured via typescript-tools.nvim (richer code actions)
local _ts_server, _ts_scope, _ts_detected = nil, nil, false
local function detect_typescript_server()
	if _ts_detected then return _ts_server, _ts_scope end
	_ts_detected = true

	local root_markers = { "tsconfig.json", "package.json", ".git" }
	local root = vim.fs.root(0, root_markers)

	local local_tsgo = root and (root .. "/node_modules/.bin/tsgo") or nil
	local local_tsc = root and (root .. "/node_modules/.bin/tsc") or nil

	-- Resolution: always local before global; preferTsGo controls tsc-vs-tsgo order
	-- Each candidate: { binary, server_type, scope }
	local candidates = config.preferTsGo
		and {
			{ local_tsgo, "tsgo", "local" },
			{ local_tsc, "tsserver", "local" },
			{ "tsgo", "tsgo", "global" },
			{ "tsc", "tsserver", "global" },
		}
		or {
			{ local_tsc, "tsserver", "local" },
			{ local_tsgo, "tsgo", "local" },
			{ "tsc", "tsserver", "global" },
			{ "tsgo", "tsgo", "global" },
		}

	for _, c in ipairs(candidates) do
		local bin, server, scope = c[1], c[2], c[3]
		if bin and vim.fn.executable(bin) == 1 then
			_ts_server, _ts_scope = server, scope
			break
		end
	end

	return _ts_server, _ts_scope
end

vim.api.nvim_create_user_command("TsInfo", function()
	local ts, scope = detect_typescript_server()
	local root = vim.fs.root(0, { "tsconfig.json", "package.json", ".git" })
	local local_tsgo = root and (root .. "/node_modules/.bin/tsgo") or nil
	local local_tsc = root and (root .. "/node_modules/.bin/tsc") or nil
	local global_tsc = vim.fn.exepath("tsc")
	local global_tsgo = vim.fn.exepath("tsgo")
	if global_tsc == "" then global_tsc = nil end
	if global_tsgo == "" then global_tsgo = nil end

	local active = ts and (ts .. " (" .. scope .. ")") or "none"
	local lines = { "active: " .. active }
	table.insert(lines, "root: " .. (root or "-"))

	local function probe(label, bin)
		if not bin then return end
		if vim.fn.executable(bin) ~= 1 then return end
		local ver = vim.trim(vim.fn.system({ bin, "--version" }))
		table.insert(lines, label .. ": " .. bin .. " (" .. ver .. ")")
	end

	probe("local tsc", local_tsc)
	probe("local tsgo", local_tsgo)
	probe("global tsc", global_tsc)
	probe("global tsgo", global_tsgo)

	table.insert(lines, "config: preferTsGo=" .. tostring(config.preferTsGo))

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "Show TypeScript server info" })

return {
	-- LSP installer (install servers with :Mason)
	-- Recommended servers: html, cssls, tailwindcss, clangd, rust_analyzer,
	-- gopls, bashls, yamlls, taplo, zls, prismals, dockerls, jsonls, pyright, lua_ls
	{
		"williamboman/mason.nvim",
		config = true,
		build = ":MasonUpdate",
	},

	-- lspconfig plugin (only needed internally by typescript-tools.nvim)
	{ "neovim/nvim-lspconfig", lazy = true },

	-- Native LSP setup (Neovim 0.12 API — no lspconfig needed)
	{
		"hrsh7th/cmp-nvim-lsp",
		dependencies = { "williamboman/mason.nvim" },
		cond = not lsp_disabled,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local server_specs = {
				{ name = "html", cmd = "vscode-html-language-server" },
				{ name = "cssls", cmd = "vscode-css-language-server" },
				{ name = "tailwindcss", cmd = "tailwindcss-language-server" },
				{
					name = "lua_ls",
					cmd = "lua-language-server",
					opts = {
						settings = {
							Lua = {
								diagnostics = { globals = { "vim" } },
							},
						},
					},
				},
				{ name = "clangd", cmd = "clangd" },
				{ name = "rust_analyzer", cmd = "rust-analyzer" },
				{ name = "gopls", cmd = "gopls" },
				{
					name = "bashls",
					cmd = "bash-language-server",
					opts = {
						settings = {
							bashIde = {
								includeAllWorkspaceSymbols = true,
							},
						},
					},
				},
				{ name = "yamlls", cmd = "yaml-language-server" },
				{ name = "taplo", cmd = "taplo" },
				{ name = "zls", cmd = "zls" },
				{ name = "prismals", cmd = "prisma-language-server" },
				{ name = "dockerls", cmd = "docker-langserver" },
				{ name = "jsonls", cmd = "vscode-json-language-server" },
				{ name = "pyright", cmd = "pyright-langserver" },
			}

			local function server_available(cmd)
				return not cmd or cmd == "" or vim.fn.executable(cmd) == 1
			end

			-- LSP keybindings (0.12 defaults: K, grr, gra, grn, gri, grt, grx)
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buf = ev.buf, silent = true }

					vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))

					-- Go to file - tries LSP definition first, falls back to default gf
					vim.keymap.set("n", "gf", function()
						local params = vim.lsp.util.make_position_params(0, "utf-8")
						vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
							if err or not result or vim.tbl_isempty(result) then
								local ok, _ = pcall(vim.cmd, "normal! gf")
								if not ok then
									vim.notify("No file found under cursor", vim.log.levels.WARN)
								end
							else
								vim.lsp.util.jump_to_location(result[1], "utf-8")
							end
						end)
					end, vim.tbl_extend("force", opts, { desc = "Go to file (LSP-aware)" }))

					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
				end,
			})

			-- Register language servers (native vim.lsp.config)
			local enabled = {}
			for _, spec in ipairs(server_specs) do
				if server_available(spec.cmd) then
					local opts = vim.tbl_extend("force", { capabilities = capabilities }, spec.opts or {})
					vim.lsp.config(spec.name, opts)
					table.insert(enabled, spec.name)
				end
			end

			-- TypeScript: tsgo native LSP (upstream nvim-lspconfig settings)
			local ts_server, _ = detect_typescript_server()
			if ts_server == "tsgo" then
				vim.lsp.config("tsgo", {
					cmd = function(dispatchers, cfg)
						local cmd = "tsgo"
						local local_cmd = (cfg or {}).root_dir and cfg.root_dir .. "/node_modules/.bin/tsgo"
						if local_cmd and vim.fn.executable(local_cmd) == 1 then
							cmd = local_cmd
						end
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
						if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
							return
						end
						if deno_root and (not project_root or #deno_root >= #project_root) then
							return
						end
						on_dir(project_root or vim.fn.getcwd())
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
					capabilities = capabilities,
				})
				table.insert(enabled, "tsgo")
			end

			if #enabled > 0 then
				vim.lsp.enable(enabled)
			end
		end,
	},

	-- TypeScript via tsserver (when detection picks tsc over tsgo)
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		cond = not lsp_disabled,
		config = function()
			local ts_server, _ = detect_typescript_server()

			if ts_server == "tsserver" then
				-- Use typescript-tools with local tsc/tsserver
				require("typescript-tools").setup({
					settings = {
						expose_as_code_action = {
							"add_missing_imports",
							"remove_unused",
							"organize_imports",
							"fix_all",
						},
					},
				})
			elseif ts_server == nil then
				-- No TypeScript server available - show warning on first TS file open
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
					once = true,
					callback = function()
						vim.notify(
							"No TypeScript server found. Install @typescript/native-preview (tsgo) or typescript in your project.",
							vim.log.levels.WARN
						)
					end,
				})
			end
			-- If ts_server == "tsgo", do nothing here (handled in native LSP setup)
		end,
	},
}
