local vim = vim
local M = {}

local labels = {
	NvimTree = "NvimTree",
	["neo-tree"] = "Neo-tree",
	lazy = "Lazy",
	mason = "Mason",
	fugitive = "Fugitive",
	TelescopePrompt = "Telescope",
	alpha = "Dashboard",
	dashboard = "Dashboard",
	Trouble = "Trouble",
	trouble = "Trouble",
}

local function escape(str)
	return (str:gsub("%%", "%%%%"))
end

local function label(bufnr, filetype, buftype)
	local name = vim.api.nvim_buf_get_name(bufnr)

	if buftype == "help" then
		return "Help " .. vim.fn.fnamemodify(name, ":t:r")
	elseif buftype == "quickfix" then
		local winid = vim.g.statusline_winid or 0
		local info = vim.fn.getwininfo(winid)[1]
		return (info and info.loclist == 1) and "Location List" or "Quickfix"
	elseif buftype == "terminal" then
		local title = vim.b[bufnr].term_title or name
		if title:match("^term://") then
			title = vim.fn.fnamemodify(title:match("([^:]+)$"), ":t")
		end
		return "Terminal " .. title
	elseif filetype == "oil" then
		return "Oil " .. vim.fn.fnamemodify((name:gsub("^oil://", "")), ":~")
	end

	return labels[filetype] or filetype
end

local function find_override(list, key)
	if not list or key == "" then
		return nil
	end
	if type(list[key]) == "function" then
		return list[key]
	end
	for _, value in ipairs(list) do
		if value == key then
			return true
		end
	end
	return nil
end

function M.render(config, components)
	local special = config.special
	if not special or special.enabled == false then
		return nil
	end

	local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
	local filetype = vim.bo[bufnr].filetype
	local buftype = vim.bo[bufnr].buftype

	local override = find_override(special.filetypes, filetype) or find_override(special.buftypes, buftype)
	if not override then
		return nil
	end

	local ctx = {
		bufnr = bufnr,
		filetype = filetype,
		buftype = buftype,
		label = escape(label(bufnr, filetype, buftype)),
		config = config,
		components = components,
	}

	local render = type(override) == "function" and override or special.render
	if render then
		return render(ctx) or ""
	end

	local mode = config.components.mode and components.mode.render(config) or ""
	local left = mode ~= "" and (mode .. config.separators.left.component .. ctx.label) or ctx.label
	return left .. "%="
end

return M
