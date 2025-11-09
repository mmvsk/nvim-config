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
