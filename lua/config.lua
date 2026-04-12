-- User configuration
-- This file contains user preferences that can be toggled

return {
	-- TypeScript LSP: prefer tsgo over tsc
	-- Resolution always tries local before global.
	-- When false: local tsc -> local tsgo -> global tsc -> global tsgo
	-- When true:  local tsgo -> local tsc -> global tsgo -> global tsc
	preferTsGo = true,
}
