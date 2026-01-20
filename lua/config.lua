-- User configuration
-- This file contains user preferences that can be toggled

return {
	-- TypeScript LSP: prefer legacy tsc over tsgo
	-- When true: local tsc -> global tsc -> local tsgo -> global tsgo
	-- When false: local tsgo -> local tsc -> global tsgo (default)
	preferTypescriptLegacy = true,
}
