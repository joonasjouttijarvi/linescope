local vim = vim
local M = {}

function M.render(config)
	local result = ""

	if config.position.show_line_column then
		local line_col = string.format("%4d:%-3d", vim.fn.line("."), vim.fn.col("."))
		result = result .. line_col
	end

	if config.position.show_progress then
		local total_lines = string.format("%-3d", vim.fn.line("$"))
		result = result .. config.position.progress_icon .. " " .. total_lines
	end

	return result
end

return M
