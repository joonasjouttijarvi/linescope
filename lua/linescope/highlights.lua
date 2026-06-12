local vim = vim
local M = {}

local colors = require("linescope.utils.colors")
local mode_groups = require("linescope.components.mode").groups
local latte = colors.latte
local mocha = colors.mocha
local mode_colors = colors.mode_colors

local function hl(group, fg, bg)
	local opts = { fg = fg }
	if bg and bg ~= "NONE" then
		opts.bg = bg
	end
	vim.api.nvim_set_hl(0, group, opts)
end

function M.setup(config)
	M.refresh(config)

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("LineScopeHighlights", { clear = true }),
		callback = function()
			M.refresh(config)
		end,
	})
end

function M.refresh(config)
	local bg = config.background

	if config.text_color then
		hl("StatusLine", config.text_color, bg)
	end

	hl("GitAdded", "#a6e3a1", bg)
	hl("GitModified", "#dc8a78", bg)
	hl("GitDeleted", "#f38ba8", bg)
	hl("GitStagedAdded", "#a6e3a1", bg)
	hl("GitStagedModified", "#4c4f69", bg)
	hl("GitStagedDeleted", "#4c4f69", bg)
	hl("GitUntracked", "#4c4f69", bg)
	hl("GitRenamed", "#b4b4b4", bg)
	hl("GitCopied", "#4f5b66", bg)
	hl("GitUnmerged", "#ff6c6b", bg)
	hl("GitIncoming", "#8BD5CA", bg)
	hl("GitUnpushed", "#ff9e64", bg)
	hl("GitConflict", "#ff6c6b", bg)
	hl("GitDiff", "#4c4f69", bg)

	-- Branch type highlights
	hl("LineScopeBranchMain", mocha.sapphire, bg)
	hl("LineScopeBranchAttached", mocha.sapphire, bg)
	hl("LineScopeBranchDetached", mocha.lavender, bg)
	hl("LineScopeBranchFeature", latte.rosewater, bg)
	hl("LineScopeBranchFix", latte.red, bg)
	hl("LineScopeBranchMisc", mocha.yellow, bg)

	-- Mode highlights
	local fallback = config.text_color or latte.text
	for key, suffix in pairs(mode_groups) do
		local color = (config.mode.colors and config.mode.colors[key]) or mode_colors[key] or fallback
		hl("LineScopeMode" .. suffix, color, bg)
	end
	local recording = (config.mode.colors and config.mode.colors.recording) or mode_colors.recording or fallback
	hl("LineScopeModeRecording", recording, bg)
	hl("LineScopeModeOther", fallback, bg)

	-- Copilot highlights
	hl("CopilotEnabled", config.copilot.colors.enabled, bg)
	hl("CopilotDisabled", config.copilot.colors.disabled, bg)
end

return M
