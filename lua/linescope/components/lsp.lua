local vim = vim
local M = {}

local severity = vim.diagnostic.severity

local levels = {
	{ severity = severity.ERROR, group = "DiagnosticError", icon = "error_icon" },
	{ severity = severity.WARN, group = "DiagnosticWarn", icon = "warning_icon" },
	{ severity = severity.HINT, group = "DiagnosticHint", icon = "hint_icon" },
	{ severity = severity.INFO, group = "DiagnosticInfo", icon = "info_icon" },
}

function M.render(config)
	local counts = vim.diagnostic.count(0)
	local parts = {}

	for _, level in ipairs(levels) do
		local count = counts[level.severity]
		if count and count > 0 then
			table.insert(parts, string.format(" %%#%s#%s %d ", level.group, config.lsp[level.icon], count))
		end
	end

	if #parts == 0 then
		return ""
	end

	return table.concat(parts) .. "%*"
end

return M
