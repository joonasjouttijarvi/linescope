local vim = vim
local M = {}

local colors = require("linescope.utils.colors")
local mode_colors = colors.mode_colors
local textColor = colors.latte.text

function M.render(config)
	local mode = vim.api.nvim_get_mode().mode
	local recording = vim.fn.reg_recording()
	local is_recording = recording ~= ""

	local mode_name
	local modeColor

	if is_recording then
		mode_name = config.mode.names.recording or ("RECORDING @" .. recording)
		modeColor = config.mode.colors and config.mode.colors.recording or mode_colors.recording or textColor
	else
		mode_name = config.mode.names[mode] or mode:upper()
		modeColor = config.mode.colors and config.mode.colors[mode] or mode_colors[mode] or textColor
	end

	vim.cmd("highlight ModeHighlight guifg=" .. modeColor .. " guibg=" .. config.background)

	return "%#ModeHighlight#" .. mode_name .. "%* "
end

return M
