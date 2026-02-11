local vim = vim
local M = {}

local cache = { value = nil, checked = false }

function M.render(config)
	local function is_copilot_enabled()
		if cache.checked then
			return cache.value
		end

		local legacy_ok, legacy_result = pcall(vim.fn["copilot#Enabled"])
		if legacy_ok and legacy_result == 1 then
			cache = { value = true, checked = true }
			return true
		end

		local lsp_clients = vim.lsp.get_clients()
		for _, client in ipairs(lsp_clients) do
			if client.name == "copilot" then
				cache = { value = true, checked = true }
				return true
			end
		end

		cache = { value = false, checked = true }
		return false
	end

	if is_copilot_enabled() then
		return "%#CopilotEnabled#" .. config.copilot.enabled_icon .. "%*"
	else
		return "%#CopilotDisabled#" .. config.copilot.disabled_icon .. "%*"
	end
end

function M.create_autocmds()
	vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
		group = vim.api.nvim_create_augroup("LineScopeCopilot", { clear = true }),
		callback = function()
			cache = { value = nil, checked = false }
		end,
	})
end

return M
