local M = {}
local vim = vim

M.config = {
	background = "NONE",
	auto_update = true,

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
		icons = true,
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
			added = "",
			modified = "",
			deleted = "",
			renamed = "",
			untracked = "?",
			staged_added = "",
			staged_modified = "",
			staged_deleted = "",
			unpushed = "⇡",
			incoming = "⇣",
			diff = "~",
			copied = "󰆏",
			unmerged = "",
			conflict = "",
		},
	},

	lsp = {
		diagnostics_icon = "",
		error_icon = "",
		warning_icon = "",
		info_icon = "",
		hint_icon = "",
		show_message = true,
		message_length = 30,
	},

	copilot = {
		enabled_icon = "",
		disabled_icon = "",
		colors = {
			enabled = "#6c6f85",
			disabled = "#6E738D",
		},
	},

	position = {
		show_line_column = true,
		show_progress = true,
		progress_icon = "☰",
	},

	separators = {
		left = {
			section = " ", -- separator between sections on left side
			component = " | ", -- separator between components
		},
		right = {
			section = " ", -- separator between sections on right side
			component = " | ", -- separator between components
		},
	},

	branch_lists = {
		main_branches = nil,
		feature_branches = nil,
		fix_branches = nil,
		misc_branches = nil,
	},
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

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

	M.config.status_mappings = lists.status_mappings

	require("linescope.highlights").setup(M.config)
	require("linescope.statusline").setup(M.config)

	return M
end

return M
