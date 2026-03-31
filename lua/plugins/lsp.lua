-- LSP Configuration: Language servers, Mason installer

local lsp_disabled = vim.env.NVIM_LSP_DISABLE == "1"

if lsp_disabled then
	return {}
end

local config = require("config")

-- TypeScript server detection (cached — result computed once per session)
-- tsgo (native Go binary) and tsserver (Node-based) are mutually exclusive:
--   tsgo detected → configured via native vim.lsp.config
--   tsserver detected → configured via typescript-tools.nvim (richer code actions)
local _ts_server, _ts_cmd, _ts_detected = nil, nil, false
local function detect_typescript_server()
	if _ts_detected then return _ts_server, _ts_cmd end
	_ts_detected = true

	local root_markers = { "tsconfig.json", "package.json", ".git" }
	local root = vim.fs.root(0, root_markers)

	local local_tsgo = root and (root .. "/node_modules/.bin/tsgo") or nil
	local local_tsc = root and (root .. "/node_modules/.bin/tsc") or nil

	if config.preferTypescriptLegacy then
		-- Prefer tsc (typescript-tools): local tsc -> global tsc -> local tsgo -> global tsgo
		if local_tsc and vim.fn.executable(local_tsc) == 1 then
			_ts_server = "tsserver"
		elseif vim.fn.executable("tsc") == 1 then
			_ts_server = "tsserver"
		elseif local_tsgo and vim.fn.executable(local_tsgo) == 1 then
			_ts_server, _ts_cmd = "tsgo", { local_tsgo, "--lsp", "--stdio" }
		elseif vim.fn.executable("tsgo") == 1 then
			_ts_server, _ts_cmd = "tsgo", { "tsgo", "--lsp", "--stdio" }
		end
	else
		-- Default: local tsgo -> local tsc -> global tsgo
		if local_tsgo and vim.fn.executable(local_tsgo) == 1 then
			_ts_server, _ts_cmd = "tsgo", { local_tsgo, "--lsp", "--stdio" }
		elseif local_tsc and vim.fn.executable(local_tsc) == 1 then
			_ts_server = "tsserver"
		elseif vim.fn.executable("tsgo") == 1 then
			_ts_server, _ts_cmd = "tsgo", { "tsgo", "--lsp", "--stdio" }
		end
	end

	return _ts_server, _ts_cmd
end

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

			-- TypeScript: tsgo native LSP (if available)
			local ts_server, ts_cmd = detect_typescript_server()
			if ts_server == "tsgo" and ts_cmd then
				vim.lsp.config("tsgo", {
					cmd = ts_cmd,
					filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
					root_markers = { "tsconfig.json", "package.json", ".git" },
					capabilities = capabilities,
				})
				table.insert(enabled, "tsgo")
			end

			if #enabled > 0 then
				vim.lsp.enable(enabled)
			end
		end,
	},

	-- TypeScript via tsserver (fallback when tsgo not available)
	-- Detects: local tsgo -> local tsc -> global tsgo -> warning
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
