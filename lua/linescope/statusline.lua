local vim = vim
local M = {}

local components = {}
local config = nil

function M.setup(cfg)
	config = cfg

	components = {
		mode = require("linescope.components.mode"),
		file = require("linescope.components.file"),
		git = require("linescope.components.git"),
		lsp = require("linescope.components.lsp"),
		copilot = require("linescope.components.copilot"),
		position = require("linescope.components.position"),
	}

	components.git.create_autocmds(config)
	components.copilot.create_autocmds()

	vim.o.statusline = "%!v:lua.require'linescope.statusline'.render()"
end

local function render_side(names)
	local rendered = {}
	for _, name in ipairs(names) do
		if config.components[name] and components[name] then
			local segment = components[name].render(config)
			if segment and segment ~= "" then
				table.insert(rendered, segment)
			end
		end
	end
	return rendered
end

function M.render()
	if not config then
		return ""
	end

	local left = render_side(config.component_order.left)
	local right = render_side(config.component_order.right)

	return table.concat(left, config.separators.left.component)
		.. "%="
		.. table.concat(right, config.separators.right.component)
end

return M
