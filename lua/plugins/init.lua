-- Plugin configuration entry point
-- Loads all plugin modules: ui, lsp, editor, git, coding

return {
	-- Load all plugin modules
	{ import = "plugins.ui" },
	{ import = "plugins.lsp" },
	{ import = "plugins.editor" },
	{ import = "plugins.git" },
	{ import = "plugins.coding" },
}
