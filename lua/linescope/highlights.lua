local vim = vim
local M = {}

local colors = require("linescope.utils.colors")
local catppuccin = colors.latte

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
	local textColor = catppuccin.text
	local bgColor = config.background

	vim.cmd("highlight StatusLine guifg=" .. textColor .. " guibg=" .. bgColor)

	vim.cmd("highlight GitAdded guifg=#a6e3a1 guibg=" .. bgColor)
	vim.cmd("highlight GitModified guifg=#dc8a78 guibg=" .. bgColor)
	vim.cmd("highlight GitDeleted guifg=#f38ba8 guibg=" .. bgColor)
	vim.cmd("highlight GitStagedAdded guifg=#a6e3a1 guibg=" .. bgColor)
	vim.cmd("highlight GitStagedModified guifg=#4c4f69 guibg=" .. bgColor)
	vim.cmd("highlight GitStagedDeleted guifg=#4c4f69 guibg=" .. bgColor)
	vim.cmd("highlight GitUntracked guifg=#4c4f69 guibg=" .. bgColor)
	vim.cmd("highlight GitRenamed guifg=#b4b4b4 guibg=" .. bgColor)
	vim.cmd("highlight GitCopied guifg=#4f5b66 guibg=" .. bgColor)
	vim.cmd("highlight GitUnmerged guifg=#ff6c6b guibg=" .. bgColor)
	vim.cmd("highlight GitIncoming guifg=#8BD5CA guibg=" .. bgColor)
	vim.cmd("highlight GitUnpushed guifg=#ff9e64 guibg=" .. bgColor)
	vim.cmd("highlight GitConflict guifg=#ff6c6b guibg=" .. bgColor)
	vim.cmd("highlight GitDiff guifg=#4c4f69 guibg=" .. bgColor)

	-- Copilot highlights
	vim.cmd("highlight CopilotEnabled guifg=" .. config.copilot.colors.enabled .. " guibg=NONE")
	vim.cmd("highlight CopilotDisabled guifg=" .. config.copilot.colors.disabled .. " guibg=NONE")
end

return M
