local vim = vim
local M = {}

M.groups = {
	n = "Normal",
	i = "Insert",
	v = "Visual",
	V = "VisualLine",
	["\22"] = "VisualBlock",
	c = "Command",
	R = "Replace",
	t = "Terminal",
}

function M.render(config)
	local recording = vim.fn.reg_recording()
	if recording ~= "" then
		local name = config.mode.names.recording or ("RECORDING @" .. recording)
		return "%#LineScopeModeRecording#" .. name .. "%*"
	end

	local mode = vim.api.nvim_get_mode().mode
	local suffix = M.groups[mode]
	local group = suffix and ("LineScopeMode" .. suffix) or "LineScopeModeOther"
	local name = config.mode.names[mode] or mode:upper()

	return "%#" .. group .. "#" .. name .. "%*"
end

return M
