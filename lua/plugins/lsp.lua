-- LSP Configuration: Language servers, Mason installer

return {
	-- LSP installer
	{
		"williamboman/mason.nvim",
		config = true,
		build = ":MasonUpdate",
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				handlers = {
					ts_ls = function() end,
				},
				ensure_installed = {
					"html",
					"cssls",
					"tailwindcss",

					"clangd",
					"rust_analyzer",
					"gopls",
					"bashls",
					"yamlls",
					"taplo",
					"zls",
					"prismals",
					"dockerls",
					"jsonls",
					"pyright",

					"lua_ls",
				},
			})
		end,
	},

	-- Native LSP support
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Configure servers with filetypes (only start when needed)
			vim.lsp.config("html", {
				capabilities = capabilities,
				filetypes = { "html" },
			})
			vim.lsp.config("cssls", {
				capabilities = capabilities,
				filetypes = { "css", "scss", "less" },
			})
			vim.lsp.config("tailwindcss", {
				capabilities = capabilities,
				filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
			})
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				filetypes = { "lua" },
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			})
			vim.lsp.config("clangd", {
				capabilities = capabilities,
				filetypes = { "c", "cpp", "objc", "objcpp" },
			})
			vim.lsp.config("rust_analyzer", {
				capabilities = capabilities,
				filetypes = { "rust" },
			})
			vim.lsp.config("gopls", {
				capabilities = capabilities,
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
			})
			vim.lsp.config("bashls", {
				capabilities = capabilities,
				filetypes = { "sh", "bash" },
			})
			vim.lsp.config("yamlls", {
				capabilities = capabilities,
				filetypes = { "yaml", "yaml.docker-compose" },
			})
			vim.lsp.config("taplo", {
				capabilities = capabilities,
				filetypes = { "toml" },
			})
			vim.lsp.config("zls", {
				capabilities = capabilities,
				filetypes = { "zig" },
			})
			vim.lsp.config("prismals", {
				capabilities = capabilities,
				filetypes = { "prisma" },
			})
			vim.lsp.config("dockerls", {
				capabilities = capabilities,
				filetypes = { "dockerfile" },
			})
			vim.lsp.config("jsonls", {
				capabilities = capabilities,
				filetypes = { "json", "jsonc" },
			})
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				filetypes = { "python" },
			})

			-- Enable servers (will auto-start based on filetypes above)
			vim.lsp.enable("html")
			vim.lsp.enable("cssls")
			vim.lsp.enable("tailwindcss")
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("clangd")
			vim.lsp.enable("rust_analyzer")
			vim.lsp.enable("gopls")
			vim.lsp.enable("bashls")
			vim.lsp.enable("yamlls")
			vim.lsp.enable("taplo")
			vim.lsp.enable("zls")
			vim.lsp.enable("prismals")
			vim.lsp.enable("dockerls")
			vim.lsp.enable("jsonls")
			vim.lsp.enable("pyright")
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
