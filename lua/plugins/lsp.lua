-- LSP Configuration: Language servers, Mason installer

local lsp_disabled = vim.env.NVIM_LSP_DISABLE == "1"

if lsp_disabled then
	return {}
end

local unpack_fn = table.unpack or unpack
local config = require("config")

-- TypeScript LSP detection
-- preferTypescriptLegacy: local tsc -> global tsc -> local tsgo -> global tsgo
-- default: local tsgo -> local tsc -> global tsgo
local function detect_typescript_server()
	local root_markers = { "tsconfig.json", "package.json", ".git" }
	local root = vim.fs.root(0, root_markers)

	local local_tsgo = root and (root .. "/node_modules/.bin/tsgo") or nil
	local local_tsc = root and (root .. "/node_modules/.bin/tsc") or nil

	if config.preferTypescriptLegacy then
		-- Prefer tsc (typescript-tools): local tsc -> global tsc -> local tsgo -> global tsgo
		if local_tsc and vim.fn.executable(local_tsc) == 1 then
			return "tsserver", nil
		elseif vim.fn.executable("tsc") == 1 then
			return "tsserver", nil
		elseif local_tsgo and vim.fn.executable(local_tsgo) == 1 then
			return "tsgo", { local_tsgo, "--lsp", "--stdio" }
		elseif vim.fn.executable("tsgo") == 1 then
			return "tsgo", { "tsgo", "--lsp", "--stdio" }
		end
	else
		-- Default: local tsgo -> local tsc -> global tsgo
		if local_tsgo and vim.fn.executable(local_tsgo) == 1 then
			return "tsgo", { local_tsgo, "--lsp", "--stdio" }
		elseif local_tsc and vim.fn.executable(local_tsc) == 1 then
			return "tsserver", nil
		elseif vim.fn.executable("tsgo") == 1 then
			return "tsgo", { "tsgo", "--lsp", "--stdio" }
		end
	end

	return nil, nil
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

	-- Native LSP support (Neovim 0.11+ API)
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
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
				{ name = "bashls", cmd = "bash-language-server" },
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

			-- Set up LSP keybindings using LspAttach autocmd (more reliable)
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }

					-- Go to definition (works with TypeScript path aliases via LSP)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))

					-- Go to file - smart function that tries LSP first, falls back to default gf
					vim.keymap.set("n", "gf", function()
						-- Try LSP definition first (works for import paths with aliases)
						local params = vim.lsp.util.make_position_params()
						vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
							if err or not result or vim.tbl_isempty(result) then
								-- Fall back to default gf behavior
								local ok, _ = pcall(vim.cmd, "normal! gf")
								if not ok then
									vim.notify("No file found under cursor", vim.log.levels.WARN)
								end
							else
								vim.lsp.util.jump_to_location(result[1], "utf-8")
							end
						end)
					end, vim.tbl_extend("force", opts, { desc = "Go to file (LSP-aware)" }))

					-- Other useful LSP keymaps
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
					vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
					vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
				end,
			})

			-- Neovim 0.11+ has native vim.lsp.config API, 0.10 uses lspconfig
			if vim.fn.has("nvim-0.11") == 1 then
				local enabled = {}
				for _, spec in ipairs(server_specs) do
					if server_available(spec.cmd) then
						local opts = vim.tbl_extend("force", { capabilities = capabilities }, spec.opts or {})
						vim.lsp.config(spec.name, opts)
						table.insert(enabled, spec.name)
					end
				end
				if #enabled > 0 then
					vim.lsp.enable(unpack_fn(enabled))
				end
			else
				-- Legacy API (0.10 and earlier). Only start servers that are installed/executable.
				local lspconfig = require("lspconfig")
				for _, spec in ipairs(server_specs) do
					if server_available(spec.cmd) and lspconfig[spec.name] then
						local opts = vim.tbl_extend("force", { capabilities = capabilities }, spec.opts or {})
						lspconfig[spec.name].setup(opts)
					end
				end
			end

			-- TypeScript: tsgo native LSP (if available)
			local ts_server, ts_cmd = detect_typescript_server()
			if ts_server == "tsgo" and ts_cmd then
				local lspconfig = require("lspconfig")
				local configs = require("lspconfig.configs")

				-- Register tsgo as a custom LSP config
				if not configs.tsgo then
					configs.tsgo = {
						default_config = {
							cmd = ts_cmd,
							filetypes = {
								"javascript",
								"javascriptreact",
								"typescript",
								"typescriptreact",
							},
							root_dir = lspconfig.util.root_pattern(
								"tsconfig.json",
								"package.json",
								".git"
							),
						},
					}
				end

				lspconfig.tsgo.setup({
					cmd = ts_cmd, -- ensure dynamic cmd is used even if config was registered before
					capabilities = capabilities,
				})
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
			-- If ts_server == "tsgo", do nothing here (handled in lspconfig section)
		end,
	},
}
