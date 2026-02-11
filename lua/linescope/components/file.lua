local vim = vim
local M = {}

local function file_icon()
	local filename = vim.fn.expand("%:t")
	local extension = vim.fn.expand("%:e")
	local icon = require("nvim-web-devicons").get_icon(filename, extension)
	if icon then
		return icon .. " "
	end
	return ""
end

function M.render(config)
	local path = ""
	local readonly = ""
	local modified = ""

	if config.file.show_path then
		if config.file.path_type == "relative" then
			path = vim.fn.expand("%:~:.")
		elseif config.file.path_type == "absolute" then
			path = vim.fn.expand("%:p")
		else
			path = vim.fn.expand("%:t") -- Filename only
		end

		if #path > config.file.max_path_length then
			path = "..." .. path:sub(-config.file.max_path_length)
		end

		if path == "" then
			path = "[No Name]"
		end
	end

	local icon = config.file.show_icon and file_icon() or ""

	if vim.bo.readonly then
		readonly = " " .. config.file.readonly_icon
	end

	if vim.bo.modified then
		modified = " " .. (config.file.modified_icon or "●")
	end

	if icon ~= "" and path ~= "" and not icon:match("%s$") then
		icon = icon .. " "
	end

	return icon .. path .. readonly .. modified
end

return M
