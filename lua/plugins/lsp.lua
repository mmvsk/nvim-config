-- LSP Configuration: Language servers, Mason installer

local lsp_disabled = vim.env.NVIM_LSP_DISABLE == "1"
local hide_missing = vim.env.NVIM_LSP_HIDE_MISSING_DEPS == "1"

if lsp_disabled then
	return {}
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

			local missing_notified = {}
			local function server_available(cmd)
				if not cmd or cmd == "" then
					return true
				end
				local ok = vim.fn.executable(cmd) == 1
				if not ok and not hide_missing and not missing_notified[cmd] then
					missing_notified[cmd] = true
					vim.notify(
						("LSP server skipped: %s (set NVIM_LSP_HIDE_MISSING_DEPS=1 to silence)"):format(cmd),
						vim.log.levels.WARN
					)
				end
				return ok
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
					vim.lsp.enable(table.unpack(enabled))
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
		end,
	},

	-- TypeScript-specific LSP (faster than ts_ls)
	-- Note: Keybindings are set via LspAttach autocmd above
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		cond = not lsp_disabled,
		config = function()
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
		end,
	},
}
