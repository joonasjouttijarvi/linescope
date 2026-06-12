local vim = vim
local M = {}

local Job = require("plenary.job")
local status_mappings = require("linescope.utils.lists").status_mappings

local cache = {
	git_repo = { value = nil, cwd = nil },
}

local git_status_result = ""
-- Populated asynchronously by update_changes; lets render() avoid shelling out.
local head_cache = { branch = "", short_sha = "" }

local DEBOUNCE_MS = 150
local update_scheduled = false

local function is_git_repo()
	local uv = vim.uv or vim.loop
	local cwd = uv.cwd()
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

local function format_status(count, icon, highlight)
	return count > 0 and string.format("%s%s %d ", highlight, icon, count) or ""
end

local function build_status(result, config)
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
	local status = table.concat(status_parts)
	if status ~= "" then
		status = status .. "%*"
	end
	return status
end

local function update_changes(config)
	if not is_git_repo() then
		git_status_result = ""
		head_cache = { branch = "", short_sha = "" }
		return
	end

	local result = {
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
	}

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

	local jobs_remaining = 6

	-- Must run for every job, success or failure: jobs referencing @{u}
	-- fail when the branch has no upstream, and the refresh still has to fire.
	local function on_job_complete()
		jobs_remaining = jobs_remaining - 1
		if jobs_remaining == 0 then
			git_status_result = build_status(result, config)
			vim.schedule(function()
				vim.api.nvim_command("redrawstatus")
			end)
		end
	end

	local function run(args, on_success)
		Job:new({
			command = "git",
			args = args,
			on_exit = function(j, return_val)
				if return_val == 0 then
					on_success(j:result())
				end
				on_job_complete()
			end,
		}):start()
	end

	run({ "status", "--porcelain" }, function(lines)
		for _, line in ipairs(lines) do
			parse_status_line(line)
		end
	end)

	run({ "rev-list", "@{u}..HEAD" }, function(lines)
		result.unpushed = #lines
	end)

	run({ "rev-list", "HEAD..@{u}" }, function(lines)
		result.incoming = #lines
	end)

	run({ "diff", "--numstat", "@{u}" }, function(lines)
		local added, deleted = 0, 0
		for _, line in ipairs(lines) do
			local a, d = line:match("(%d+)%s+(%d+)")
			if a and d then
				added = added + tonumber(a)
				deleted = deleted + tonumber(d)
			end
		end
		result.diff = added + deleted
	end)

	run({ "branch", "--show-current" }, function(lines)
		head_cache.branch = lines[1] or ""
	end)

	run({ "rev-parse", "--short", "HEAD" }, function(lines)
		head_cache.short_sha = lines[1] or ""
	end)
end

local function request_update(config)
	if update_scheduled then
		return
	end
	update_scheduled = true
	vim.defer_fn(function()
		update_scheduled = false
		update_changes(config)
	end, DEBOUNCE_MS)
end

function M.render(config)
	if not is_git_repo() then
		return ""
	end

	local ok, head = pcall(vim.fn.FugitiveHead)
	local branch = vim.b.gitsigns_head or (ok and head) or ""
	local result = ""

	if config.git.show_branch then
		local is_detached = false

		if branch == "" then
			branch = head_cache.branch
		end
		if branch == "" and head_cache.short_sha ~= "" then
			branch = head_cache.short_sha
			is_detached = true
		end

		if branch ~= "" then
			is_detached = is_detached
				or branch:match("^HEAD") ~= nil
				or (head_cache.short_sha ~= "" and branch == head_cache.short_sha)
				or (#branch >= 7 and branch:match("^%x+$") ~= nil)

			-- Categorize before truncating so prefixes still match
			local branch_type
			if is_detached then
				branch_type = "Detached"
			elseif vim.tbl_contains(config.branch_lists.main_branches, branch) then
				branch_type = "Main"
			elseif branch_starts_with_prefix(branch, config.branch_lists.feature_branches) then
				branch_type = "Feature"
			elseif branch_starts_with_prefix(branch, config.branch_lists.fix_branches) then
				branch_type = "Fix"
			elseif branch_starts_with_prefix(branch, config.branch_lists.misc_branches) then
				branch_type = "Misc"
			else
				branch_type = "Attached"
			end

			if #branch > config.git.max_branch_length then
				branch = branch:sub(1, config.git.max_branch_length - 2) .. ".."
			end

			local branch_icon = config.git.branch_icon or ""
			result = "%#LineScopeBranch" .. branch_type .. "#" .. branch_icon .. "%* " .. branch
		end
	end

	if config.git.show_status and git_status_result ~= "" then
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
				request_update(config)
			end,
		}
	)

	vim.api.nvim_create_autocmd("DirChanged", {
		group = group,
		callback = function()
			cache.git_repo = { value = nil, cwd = nil }
			head_cache = { branch = "", short_sha = "" }
			request_update(config)
		end,
	})

	-- Initial update
	update_changes(config)
end

return M
