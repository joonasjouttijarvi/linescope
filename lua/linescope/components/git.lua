local vim = vim
local M = {}

local Job = require("plenary.job")
local colors = require("linescope.utils.colors")
local branch_lists = require("linescope.utils.lists")
local status_mappings = branch_lists.status_mappings

local cache = {
	git_repo = { value = nil, cwd = nil },
}

local git_status_result = ""
local last_good_status = ""

local catppuccin = colors.latte
local special = colors.mocha

local feature_branch_color = catppuccin.rosewater
local fix_branch_color = catppuccin.red
local misc_branch_color = special.yellow
local detached_branch_color = special.lavender
local attached_branch_color = special.sapphire
local any_branch_color = special.sapphire

local function is_git_repo()
	local cwd = vim.loop.cwd()
	if cache.git_repo.cwd == cwd and cache.git_repo.value ~= nil then
		return cache.git_repo.value
	end

	local handle = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		local is_repo = result:match("true") ~= nil
		cache.git_repo = { value = is_repo, cwd = cwd }
		return is_repo
	end
	cache.git_repo = { value = false, cwd = cwd }
	return false
end

local function branch_starts_with_prefix(branch, prefixes)
	for _, prefix in pairs(prefixes) do
		if branch:sub(1, #prefix) == prefix then
			return true
		end
	end
	return false
end

local function update_changes(config)
	if not is_git_repo() then
		git_status_result = ""
		return
	end

	local job_cache = {
		last_modified = nil,
		data = {
			added = 0,
			modified = 0,
			deleted = 0,
			diff = 0,
			staged_added = 0,
			staged_modified = 0,
			staged_deleted = 0,
			untracked = 0,
			renamed = 0,
			copied = 0,
			unmerged = 0,
			unpushed = 0,
			incoming = 0,
			both_deleted = 0,
			added_by_us = 0,
			deleted_by_them = 0,
			added_by_them = 0,
			deleted_by_us = 0,
			both_added = 0,
			both_modified = 0,
		},
	}

	local function cache_is_valid()
		local handle = io.popen("git log -1 --format=%ct")
		if not handle then
			return false
		end
		local current_modified = handle:read("*a")
		handle:close()
		return job_cache.last_modified == current_modified
	end

	local function update_cache_timestamp()
		local handle = io.popen("git log -1 --format=%ct")
		if not handle then
			return
		end
		job_cache.last_modified = handle:read("*a")
		handle:close()
	end

	local result = job_cache.data

	local function parse_status_line(line)
		for pattern, key in pairs(status_mappings) do
			if line:match(pattern) then
				if type(key) == "table" then
					for _, subkey in ipairs(key) do
						result[subkey] = result[subkey] + 1
					end
				else
					result[key] = result[key] + 1
				end
			end
		end
	end

	local function parse_status(lines)
		for _, line in ipairs(lines) do
			parse_status_line(line)
		end
	end

	local function parse_unpushed(lines)
		result.unpushed = #lines
	end

	local function parse_incoming(lines)
		result.incoming = #lines
	end

	local function parse_diff(lines)
		local added, deleted = 0, 0
		for _, line in ipairs(lines) do
			local a, d = line:match("(%d+)%s+(%d+)")
			if a and d then
				added = added + tonumber(a)
				deleted = deleted + tonumber(d)
			end
		end
		result.diff = added + deleted
	end

	local function format_status(count, icon, highlight)
		return count > 0 and string.format("%s%s %d ", highlight, icon, count) or ""
	end

	local function update_highlight()
		local status_parts = {
			format_status(result.unpushed, config.git.icons.unpushed, "%#GitUnpushed#"),
			format_status(result.added, config.git.icons.added, "%#GitAdded#"),
			format_status(result.staged_added, config.git.icons.staged_added, "%#GitStagedAdded#"),
			format_status(result.modified, config.git.icons.modified, "%#GitModified#"),
			format_status(result.staged_modified, config.git.icons.staged_modified, "%#GitStagedModified#"),
			format_status(result.deleted, config.git.icons.deleted, "%#GitDeleted#"),
			format_status(result.staged_deleted, config.git.icons.staged_deleted, "%#GitStagedDeleted#"),
			format_status(result.untracked, config.git.icons.untracked, "%#GitUntracked#"),
			format_status(result.renamed, config.git.icons.renamed, "%#GitRenamed#"),
			format_status(result.diff, config.git.icons.diff, "%#GitDiff#"),
			format_status(result.copied, config.git.icons.copied, "%#GitCopied#"),
			format_status(result.unmerged, config.git.icons.unmerged, "%#GitUnmerged#"),
			format_status(result.incoming, config.git.icons.incoming, "%#GitIncoming#"),
			format_status(result.both_deleted, config.git.icons.conflict, "%#GitConflict#"),
			format_status(result.added_by_us, config.git.icons.conflict, "%#GitConflict#"),
			format_status(result.deleted_by_them, config.git.icons.conflict, "%#GitConflict#"),
			format_status(result.added_by_them, config.git.icons.conflict, "%#GitConflict#"),
			format_status(result.deleted_by_us, config.git.icons.conflict, "%#GitConflict#"),
			format_status(result.both_added, config.git.icons.conflict, "%#GitConflict#"),
			format_status(result.both_modified, config.git.icons.conflict, "%#GitConflict#"),
		}
		git_status_result = table.concat(status_parts)
	end

	local function refresh_statusline()
		update_highlight()
		last_good_status = git_status_result
		vim.schedule(function()
			vim.api.nvim_command("redrawstatus")
		end)
	end

	if cache_is_valid() then
		refresh_statusline()
		return
	end

	-- Display cached value initially
	git_status_result = last_good_status
	vim.schedule(function()
		vim.api.nvim_command("redrawstatus")
	end)

	-- Update cache in the background
	local jobs_remaining = 4

	local function on_job_complete()
		jobs_remaining = jobs_remaining - 1
		if jobs_remaining == 0 then
			update_cache_timestamp()
			refresh_statusline()
		end
	end

	Job:new({
		command = "git",
		args = { "status", "--porcelain" },
		on_exit = function(j, return_val)
			if return_val == 0 then
				parse_status(j:result())
				on_job_complete()
			end
		end,
	}):start()

	Job:new({
		command = "git",
		args = { "rev-list", "@{u}..HEAD" },
		on_exit = function(j, return_val)
			if return_val == 0 then
				parse_unpushed(j:result())
				on_job_complete()
			end
		end,
	}):start()

	Job:new({
		command = "git",
		args = { "rev-list", "HEAD..@{u}" },
		on_exit = function(j, return_val)
			if return_val == 0 then
				parse_incoming(j:result())
				on_job_complete()
			end
		end,
	}):start()

	Job:new({
		command = "git",
		args = { "diff", "--numstat", "@{u}" },
		on_exit = function(j, return_val)
			if return_val == 0 then
				parse_diff(j:result())
				on_job_complete()
			end
		end,
	}):start()
end

function M.render(config)
	if not is_git_repo() then
		return ""
	end

	local ok, head = pcall(vim.fn.FugitiveHead)
	local branch = vim.b.gitsigns_head or (ok and head) or ""
	local result = ""

	if config.git.show_branch then
		if branch == "" then
			local handle = io.popen("git rev-parse --short HEAD 2>/dev/null")
			if handle then
				local commit_hash = handle:read("*a"):gsub("%s+", "")
				handle:close()
				if commit_hash ~= "" then
					branch = commit_hash
				end
			end
		end

		-- Only proceed if we have a branch name or commit hash
		if branch ~= "" then
			-- Truncate branch name if needed
			if #branch > config.git.max_branch_length then
				branch = branch:sub(1, config.git.max_branch_length - 2) .. ".."
			end

			-- Set branch icon
			local branch_icon = config.git.branch_icon or ""
			local branch_type = "misc"

			local is_detached = branch:match("^HEAD") or branch:match("^%x+$")

			-- Determine branch category
			if is_detached then
				branch_type = "detached"
			elseif vim.tbl_contains(branch_lists.main_branches, branch) then
				branch_type = "main"
			elseif branch_starts_with_prefix(branch, branch_lists.feature_branches) then
				branch_type = "feature"
			elseif branch_starts_with_prefix(branch, branch_lists.fix_branches) then
				branch_type = "fix"
			else
				branch_type = "attached"
			end

			-- Select appropriate color
			local branch_color
			if branch_type == "main" then
				branch_color = any_branch_color
			elseif branch_type == "attached" then
				branch_color = attached_branch_color
			elseif branch_type == "detached" then
				branch_color = detached_branch_color
			elseif branch_type == "feature" then
				branch_color = feature_branch_color
			elseif branch_type == "fix" then
				branch_color = fix_branch_color
			else
				branch_color = misc_branch_color
			end

			vim.cmd("highlight BranchIcon guifg=" .. branch_color)

			result = "%#BranchIcon#" .. branch_icon .. "%* " .. branch
		end
	end

	if config.git.show_status then
		result = result .. " " .. git_status_result
	end

	return result
end

function M.create_autocmds(config)
	local group = vim.api.nvim_create_augroup("LineScopeGit", { clear = true })

	vim.api.nvim_create_autocmd(
		{ "BufWritePost", "FileWritePost", "ShellCmdPost", "VimEnter", "FocusGained", "BufEnter" },
		{
			group = group,
			callback = function()
				update_changes(config)
			end,
		}
	)

	vim.api.nvim_create_autocmd("DirChanged", {
		group = group,
		callback = function()
			cache.git_repo = { value = nil, cwd = nil }
		end,
	})

	-- Initial update
	update_changes(config)
end

return M
