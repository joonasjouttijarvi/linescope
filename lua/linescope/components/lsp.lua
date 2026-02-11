local vim = vim
local M = {}

local LSP_CACHE_MS = 500
local lsp_cache = { value = "", last_update = 0 }

function M.render(config)
	local now = vim.loop.now()
	-- Return cached value if still valid
	if now - lsp_cache.last_update < LSP_CACHE_MS then
		return lsp_cache.value
	end

	local count = {}
	local levels = {
		errors = vim.diagnostic.severity.ERROR,
		warnings = vim.diagnostic.severity.WARN,
		info = vim.diagnostic.severity.INFO,
		hints = vim.diagnostic.severity.HINT,
	}

	for k, level in pairs(levels) do
		count[k] = #vim.diagnostic.get(0, { severity = level })
	end

	local diagnostics = {
		errors = "",
		warnings = "",
		hints = "",
		info = "",
	}

	local diagnosticSigns = {
		errors = config.lsp.error_icon,
		warnings = config.lsp.warning_icon,
		hints = config.lsp.hint_icon,
		info = config.lsp.info_icon,
	}

	for k, v in pairs(count) do
		if v ~= 0 then
			diagnostics[k] = " %#LspDiagnosticsSign"
				.. k:sub(1, 1):upper()
				.. k:sub(2)
				.. "#"
				.. diagnosticSigns[k]
				.. " "
				.. tostring(v)
				.. " "
		end
	end

	local result = diagnostics.errors .. diagnostics.warnings .. diagnostics.hints .. diagnostics.info .. "%#Normal#"
	lsp_cache = { value = result, last_update = now }
	return result
end

return M
