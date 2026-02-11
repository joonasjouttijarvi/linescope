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

	vim.cmd([[ set statusline=%!luaeval('Statusline()') ]])
end

function _G.Statusline()
	local segments = {}

	for _, component_name in ipairs(config.component_order.left) do
		if config.components[component_name] and components[component_name] then
			local component = components[component_name].render(config)

			if component and component ~= "" then
				table.insert(segments, component)
				table.insert(segments, config.separators.left.component)
			end
		end
	end

	table.insert(segments, "%=")

	for _, component_name in ipairs(config.component_order.right) do
		if config.components[component_name] and components[component_name] then
			local component = components[component_name].render(config)

			if component and component ~= "" then
				table.insert(segments, config.separators.right.component)
				table.insert(segments, component)
			end
		end
	end

	return table.concat(segments)
end

return M
