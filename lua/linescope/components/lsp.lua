local vim = vim
local M = {}

local severity = vim.diagnostic.severity

local levels = {
	{ severity = severity.ERROR, group = "DiagnosticError", icon = "error_icon" },
	{ severity = severity.WARN, group = "DiagnosticWarn", icon = "warning_icon" },
	{ severity = severity.HINT, group = "DiagnosticHint", icon = "hint_icon" },
	{ severity = severity.INFO, group = "DiagnosticInfo", icon = "info_icon" },
}

local progress = {}

local function escape(str)
	return (str:gsub("%%", "%%%%"))
end

local function truncate(str, max)
	if max and #str > max then
		return str:sub(1, max - 1) .. "…"
	end
	return str
end

local function get_clients(config)
	local ignored = {}
	for _, name in ipairs(config.lsp.ignore_clients or {}) do
		ignored[name] = true
	end

	local clients = {}
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if not ignored[client.name] then
			table.insert(clients, client)
		end
	end
	return clients
end

local function render_diagnostics(config)
	local counts = vim.diagnostic.count(0)
	local parts = {}

	for _, level in ipairs(levels) do
		local count = counts[level.severity]
		if count and count > 0 then
			table.insert(parts, string.format(" %%#%s#%s %d ", level.group, config.lsp[level.icon], count))
		end
	end

	if #parts == 0 then
		return ""
	end

	return table.concat(parts) .. "%*"
end

local function render_clients(config, clients)
	if not config.lsp.show_clients or #clients == 0 then
		return ""
	end

	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end

	return "%#LineScopeLspClients#" .. config.lsp.client_icon .. " " .. escape(table.concat(names, ", ")) .. "%*"
end

local function render_progress(config, clients)
	if not config.lsp.show_progress then
		return ""
	end

	for _, client in ipairs(clients) do
		local _, p = next(progress[client.id] or {})
		if p then
			local text = p.title or ""
			if p.message and p.message ~= "" then
				text = text ~= "" and (text .. ": " .. p.message) or p.message
			end
			if p.percentage then
				text = string.format("%s (%d%%)", text, p.percentage)
			end
			text = truncate(text, config.lsp.max_progress_length)
			return "%#LineScopeLspProgress#" .. config.lsp.progress_icon .. " " .. escape(text) .. "%*"
		end
	end

	return ""
end

function M.render(config)
	local clients = get_clients(config)
	local parts = {}

	for _, segment in ipairs({
		render_diagnostics(config),
		render_clients(config, clients),
		render_progress(config, clients),
	}) do
		if segment ~= "" then
			table.insert(parts, segment)
		end
	end

	return table.concat(parts, " ")
end

function M.create_autocmds()
	local group = vim.api.nvim_create_augroup("LineScopeLsp", { clear = true })

	vim.api.nvim_create_autocmd("LspProgress", {
		group = group,
		callback = function(ev)
			local value = ev.data.params.value
			if type(value) ~= "table" then
				return
			end

			local id = ev.data.client_id
			local token = ev.data.params.token
			progress[id] = progress[id] or {}

			if value.kind == "end" then
				progress[id][token] = nil
				if next(progress[id]) == nil then
					progress[id] = nil
				end
			else
				local prev = progress[id][token] or {}
				progress[id][token] = {
					title = value.title or prev.title,
					message = value.message,
					percentage = value.percentage,
				}
			end

			vim.cmd.redrawstatus()
		end,
	})

	vim.api.nvim_create_autocmd("LspDetach", {
		group = group,
		callback = function(ev)
			progress[ev.data.client_id] = nil
		end,
	})
end

return M
