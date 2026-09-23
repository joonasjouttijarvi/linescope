local M = {}
local vim = vim

M.config = {
	background = "NONE",
	auto_update = true,

	text_color = nil,

	components = {
		mode = true,
		file = true,
		git = true,
		lsp = true,
		copilot = true,
		position = true,
	},

	component_order = {
		left = { "mode", "file", "git", "lsp" },
		right = { "copilot", "position" },
	},

	mode = {
		names = {
			n = "NORMAL",
			i = "INSERT",
			v = "VISUAL",
			V = "VISUAL LINE",
			["\22"] = "V-BLOCK",
			c = "COMMAND",
			R = "REPLACE",
			t = "TERMINAL",
		},
	},

	file = {
		show_icon = true,
		show_path = true,
		path_type = "relative",
		max_path_length = 40,
		readonly_icon = "",
		modified_icon = "",
	},

	git = {
		show_branch = true,
		max_branch_length = 20,
		branch_icon = "",
		show_status = true,
		icons = {
			added = "",
			modified = "",
			deleted = "",
			renamed = "",
			untracked = "?",
			staged_added = "",
			staged_modified = "",
			staged_deleted = "",
			unpushed = "⇡",
			incoming = "⇣",
			diff = "~",
			copied = "󰆏",
			unmerged = "",
			conflict = "",
		},
	},

	lsp = {
		error_icon = "",
		warning_icon = "",
		info_icon = "",
		hint_icon = "",
		show_clients = false,
		client_icon = "",
		ignore_clients = { "copilot" },
		show_progress = true,
		progress_icon = "󰔟",
		max_progress_length = 40,
		colors = {
			clients = "#8087A2",
			progress = "#8BD5CA",
		},
	},

	copilot = {
		enabled_icon = "",
		disabled_icon = "",
		colors = {
			enabled = "#6c6f85",
			disabled = "#6E738D",
		},
	},

	position = {
		show_line_column = true,
		show_progress = true,
		progress_icon = "",
	},

	separators = {
		left = {
			component = " | ",
		},
		right = {
			component = " | ",
		},
	},

	special = {
		enabled = true,
		filetypes = {
			"NvimTree",
			"neo-tree",
			"oil",
			"lazy",
			"mason",
			"fugitive",
			"TelescopePrompt",
			"alpha",
			"dashboard",
			"Trouble",
			"trouble",
		},
		buftypes = { "help", "quickfix", "terminal" },
		render = nil,
	},

	branch_lists = {
		main_branches = nil,
		feature_branches = nil,
		fix_branches = nil,
		misc_branches = nil,
	},
}

function M.setup(opts)
	opts = opts or {}
	M.config = vim.tbl_deep_extend("force", M.config, opts)

	if opts.special then
		M.config.special.filetypes = opts.special.filetypes or M.config.special.filetypes
		M.config.special.buftypes = opts.special.buftypes or M.config.special.buftypes
	end
	if opts.lsp and opts.lsp.ignore_clients then
		M.config.lsp.ignore_clients = opts.lsp.ignore_clients
	end

	local lists = require("linescope.utils.lists")

	if not M.config.branch_lists.main_branches then
		M.config.branch_lists.main_branches = lists.main_branches
	end

	if not M.config.branch_lists.feature_branches then
		M.config.branch_lists.feature_branches = lists.feature_branches
	end

	if not M.config.branch_lists.fix_branches then
		M.config.branch_lists.fix_branches = lists.fix_branches
	end

	if not M.config.branch_lists.misc_branches then
		M.config.branch_lists.misc_branches = lists.misc_branches
	end

	require("linescope.highlights").setup(M.config)
	require("linescope.statusline").setup(M.config)

	return M
end

return M
