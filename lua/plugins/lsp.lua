-- LSP Configuration: native vim.lsp setup (Neovim 0.12) + Mason installer.
-- Per-server configs live in ~/.config/nvim/lsp/<name>.lua (auto-loaded from runtimepath).

local lsp_disabled = vim.env.NVIM_LSP_DISABLE == "1"

if lsp_disabled then
	return {}
end

return {
	-- LSP installer (install servers with :Mason)
	{
		"mason-org/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()

			-- Capabilities (global, applied to every server via the "*" config).
			local caps = vim.lsp.protocol.make_client_capabilities()
			local ok, blink = pcall(require, "blink.cmp")
			if ok then
				caps = blink.get_lsp_capabilities(caps)
			end
			vim.lsp.config("*", { capabilities = caps })

			vim.diagnostic.config({
				severity_sort = true,
				underline = true,
				update_in_insert = false,
				virtual_text = false,
				virtual_lines = { current_line = true },
				signs = true,
				float = { border = "rounded", source = true },
			})

			-- LSP keybindings (0.12 defaults already provide K, grr, gra, grn, gri, grt, grx)
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
								local ok_gf, _ = pcall(vim.cmd, "normal! gf")
								if not ok_gf then
									vim.notify("No file found under cursor", vim.log.levels.WARN)
								end
							else
								vim.lsp.util.show_document(result[1], "utf-8", { focus = true })
							end
						end)
					end, vim.tbl_extend("force", opts, { desc = "Go to file (LSP-aware)" }))

					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
				end,
			})

			-- Static server list with executable gate. cmd == nil means "always enable".
			local servers = {
				{ name = "html", cmd = "vscode-html-language-server" },
				{ name = "cssls", cmd = "vscode-css-language-server" },
				{ name = "tailwindcss", cmd = "tailwindcss-language-server" },
				{ name = "lua_ls", cmd = "lua-language-server" },
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
				{ name = "expert", cmd = "expert" },
			}

			local enabled = {}
			for _, s in ipairs(servers) do
				if s.cmd == nil or vim.fn.executable(s.cmd) == 1 then
					table.insert(enabled, s.name)
				end
			end

			-- TypeScript: pick exactly one server. Local tsgo beats global vtsls.
			local ts_server
			if vim.fn.executable("tsgo") == 1 then
				ts_server = "tsgo"
			else
				local root = vim.fs.root(0, { "package.json", "tsconfig.json", ".git" })
				if root and vim.fn.executable(root .. "/node_modules/.bin/tsgo") == 1 then
					ts_server = "tsgo"
				elseif vim.fn.executable("vtsls") == 1 then
					ts_server = "vtsls"
				end
			end

			if ts_server then
				table.insert(enabled, ts_server)
			else
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
					once = true,
					callback = function()
						vim.notify(
							"No TypeScript server. Install tsgo (@typescript/native-preview) or vtsls.",
							vim.log.levels.WARN
						)
					end,
				})
			end

			-- denols self-gates via root_markers, so it's harmless in npm projects.
			if vim.fn.executable("deno") == 1 then
				table.insert(enabled, "denols")
			end

			vim.lsp.enable(enabled)

			vim.api.nvim_create_user_command("TsInfo", function()
				vim.notify(
					"TypeScript server: " .. (ts_server or "none") .. "\ndeno on PATH: " .. tostring(vim.fn.executable("deno") == 1),
					vim.log.levels.INFO
				)
			end, { desc = "Show TypeScript server info" })
		end,
	},
}
