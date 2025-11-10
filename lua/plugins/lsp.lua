-- LSP Configuration: Language servers, Mason installer

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
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

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
				-- Modern API (0.11+)
				vim.lsp.config("html", { capabilities = capabilities })
				vim.lsp.config("cssls", { capabilities = capabilities })
				vim.lsp.config("tailwindcss", { capabilities = capabilities })
				vim.lsp.config("lua_ls", {
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
						},
					},
				})
				vim.lsp.config("clangd", { capabilities = capabilities })
				vim.lsp.config("rust_analyzer", { capabilities = capabilities })
				vim.lsp.config("gopls", { capabilities = capabilities })
				vim.lsp.config("bashls", { capabilities = capabilities })
				vim.lsp.config("yamlls", { capabilities = capabilities })
				vim.lsp.config("taplo", { capabilities = capabilities })
				vim.lsp.config("zls", { capabilities = capabilities })
				vim.lsp.config("prismals", { capabilities = capabilities })
				vim.lsp.config("dockerls", { capabilities = capabilities })
				vim.lsp.config("jsonls", { capabilities = capabilities })
				vim.lsp.config("pyright", { capabilities = capabilities })

				-- Enable all configured servers
				vim.lsp.enable("html", "cssls", "tailwindcss", "lua_ls", "clangd",
					"rust_analyzer", "gopls", "bashls", "yamlls", "taplo", "zls",
					"prismals", "dockerls", "jsonls", "pyright")
			else
				-- Legacy API (0.10 and earlier)
				local lspconfig = require("lspconfig")
				lspconfig.html.setup({ capabilities = capabilities })
				lspconfig.cssls.setup({ capabilities = capabilities })
				lspconfig.tailwindcss.setup({ capabilities = capabilities })
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
						},
					},
				})
				lspconfig.clangd.setup({ capabilities = capabilities })
				lspconfig.rust_analyzer.setup({ capabilities = capabilities })
				lspconfig.gopls.setup({ capabilities = capabilities })
				lspconfig.bashls.setup({ capabilities = capabilities })
				lspconfig.yamlls.setup({ capabilities = capabilities })
				lspconfig.taplo.setup({ capabilities = capabilities })
				lspconfig.zls.setup({ capabilities = capabilities })
				lspconfig.prismals.setup({ capabilities = capabilities })
				lspconfig.dockerls.setup({ capabilities = capabilities })
				lspconfig.jsonls.setup({ capabilities = capabilities })
				lspconfig.pyright.setup({ capabilities = capabilities })
			end
		end,
	},

	-- TypeScript-specific LSP (faster than ts_ls)
	-- Note: Keybindings are set via LspAttach autocmd above
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
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
