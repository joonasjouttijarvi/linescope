local fn, cmd, api = vim.fn, vim.cmd, vim.api
local Job = require("plenary.job")
local config = require("linescope").config
local colors = require("linescope.utils.colors")
local status_mappings = require("linescope.utils.lists").status_mappings
local branch_lists = require("linescope.utils.lists")

local catppuccin = colors.latte
local special = colors.mocha
local mode_colors = colors.mode_colors

local textColor = catppuccin.text
local bgColor = config.background
local feature_branch_color = catppuccin.rosewater
local fix_branch_color = catppuccin.red
local misc_branch_color = special.yellow
local detached_branch_color = special.lavender
local attached_branch_color = special.sapphire
local any_branch_color = special.sapphire

function Set_highlights()
    -- statusline text color
    vim.cmd("highlight StatusLine guifg=" .. textColor .. " guibg=" .. bgColor)

    -- Git highlights
    vim.cmd("highlight GitAdded guifg=#a6e3a1 guibg=" .. bgColor)
    vim.cmd("highlight GitModified guifg=#dc8a78 guibg=" .. bgColor)
    vim.cmd("highlight GitDeleted guifg=#f38ba8 guibg=" .. bgColor)
    vim.cmd("highlight GitStagedAdded guifg=#a6e3a1 guibg=" .. bgColor)
    vim.cmd("highlight GitStagedModified guifg=#4c4f69 guibg=" .. bgColor)
    vim.cmd("highlight GitStagedDeleted guifg=#4c4f69 guibg=" .. bgColor)
    vim.cmd("highlight GitUntracked guifg=#4c4f69 guibg=" .. bgColor)
    vim.cmd("highlight GitRenamed guifg=#b4b4b4 guibg=" .. bgColor)
    vim.cmd("highlight GitCopied guifg=#4f5b66 guibg=" .. bgColor)
    vim.cmd("highlight GitUnmerged guifg=#ff6c6b guibg=" .. bgColor)
    vim.cmd("highlight GitIncoming guifg=#8BD5CA guibg=" .. bgColor)
    vim.cmd("highlight GitUnpushed guifg=#ff9e64 guibg=" .. bgColor)
    vim.cmd("highlight GitConflict guifg=#ff6c6b guibg=" .. bgColor)
    vim.cmd("highlight GitDiff guifg=#4c4f69 guibg=" .. bgColor)
end

function Lsp_info()
    local count = {}
    local levels = {
        errors = vim.diagnostic.severity.ERROR,
        warnings = vim.diagnostic.severity.WARN,
        info = vim.diagnostic.severity.INFO,
        hints = vim.diagnostic.severity.HINT,
    }

    for k, level in pairs(levels) do
        count[k] = #vim.diagnostic.get(0, { severity = level })
    end

    local diagnostics = {
        errors = "",
        warnings = "",
        hints = "",
        info = "",
    }

    local diagnosticSigns = {
        errors = config.lsp.error_icon,
        warnings = config.lsp.warning_icon,
        hints = config.lsp.hint_icon,
        info = config.lsp.info_icon,
    }

    for k, v in pairs(count) do
        if v ~= 0 then
            diagnostics[k] = " %#LspDiagnosticsSign"
                .. k:sub(1, 1):upper()
                .. k:sub(2)
                .. "#"
                .. diagnosticSigns[k]
                .. " "
                .. tostring(v)
                .. " "
        end
    end

    return diagnostics.errors .. diagnostics.warnings .. diagnostics.hints .. diagnostics.info .. "%#Normal#"
end

local function is_git_repo()
    -- Check if fugitive is available first
    local has_fugitive, _ = pcall(vim.fn.FugitiveHead)
    if not has_fugitive then
        return false
    end

    -- Try to get the git branch
    local branch = vim.fn.FugitiveHead()
    return branch ~= ""
end

local git_status_result = ""
local last_good_status = ""

function Git_changes()
    if not is_git_repo() then
        git_status_result = ""
        return
    end

    local cache = {
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
        return cache.last_modified == current_modified
    end

    local function update_cache_timestamp()
        local handle = io.popen("git log -1 --format=%ct")
        if not handle then
            return
        end
        cache.last_modified = handle:read("*a")
        handle:close()
    end

    local result = cache.data
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

    function update_highlight()
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

    -- Run git status to get file changes asynchronously
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

    -- Run git rev-list to get the number of unpushed commits asynchronously
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

    -- Run git rev-list to get the number of incoming commits asynchronously
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

    -- Run git diff to get the number of diff lines asynchronously
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

function File_icon()
    local filename = fn.expand("%:t")
    local extension = fn.expand("%:e")
    local icon = require("nvim-web-devicons").get_icon(filename, extension)
    if icon then
        return icon .. " "
    end
    return ""
end

local function branch_starts_with_prefix(branch, prefixes)
    for _, prefix in pairs(prefixes) do
        if branch:sub(1, #prefix) == prefix then
            return true
        end
    end
    return false
end

-- Component functions
function Mode_component()
    local mode = api.nvim_get_mode().mode
    local recording = vim.fn.reg_recording()
    if recording ~= "" then
        mode = mode .. "(Recording @ " .. recording .. ")"
    end

    local mode_name = config.mode.names[mode] or mode:upper()
    local modeColor = config.mode.colors and config.mode.colors[mode] or mode_colors[mode] or textColor

    -- Set mode color
    vim.cmd("highlight ModeHighlight guifg=" .. modeColor .. " guibg=" .. bgColor)

    return "%#ModeHighlight#" .. mode_name .. "%* "
end

function File_component()
    local path = ""
    local readonly = ""

    if config.file.show_path then
        if config.file.path_type == "relative" then
            path = fn.expand("%:~:.")
        elseif config.file.path_type == "absolute" then
            path = fn.expand("%:p")
        else
            path = fn.expand("%:t")
        end

        -- Truncate path if needed
        if #path > config.file.max_path_length then
            path = "..." .. path:sub(-config.file.max_path_length)
        end
    end

    local icon = config.file.show_icon and File_icon() or ""

    if vim.bo.readonly then
        readonly = config.file.readonly_icon
    end

    return path .. icon .. readonly
end

function Git_component()
    if not is_git_repo() then
        return ""
    end

    local branch = fn.FugitiveHead()
    local result = ""

    if config.git.show_branch and branch ~= "" then
        -- Truncate branch name if needed
        if #branch > config.git.max_branch_length then
            branch = branch:sub(1, config.git.max_branch_length - 2) .. ".."
        end

        -- Set branch icon
        local branch_icon = config.git.branch_icon or ""
        local branch_name = branch
        local branch_type = "misc" -- Default

        -- Check if branch is detached (like HEAD or SHA)
        local is_detached = branch:match("^HEAD") or branch:match("^%x+$")

        -- Determine branch category
        if is_detached then
            branch_type = "detached" -- It's a detached HEAD or SHA
        elseif vim.tbl_contains(branch_lists.main_branches, branch) then
            branch_type = "main" -- Main branch
        elseif branch_starts_with_prefix(branch, branch_lists.feature_branches) then
            branch_type = "feature" -- Feature branch
        elseif branch_starts_with_prefix(branch, branch_lists.fix_branches) then
            branch_type = "fix" -- Fix branch
        else
            branch_type = "attached" -- Default for other attached branches
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

    if config.git.show_status then
        result = result .. " " .. git_status_result
    end

    return result
end

function Lsp_component()
    return Lsp_info()
end

function Copilot_component()
    local function is_copilot_enabled()
        -- Check the legacy GitHub/copilot.vim plugin
        local legacy_ok, legacy_result = pcall(vim.fn["copilot#Enabled"])
        if legacy_ok and legacy_result == 1 then
            return true
        end

        -- Check the new zbirenbaum/copilot.lua plugin's LSP client
        local lsp_clients = vim.lsp.get_active_clients()
        for _, client in ipairs(lsp_clients) do
            if client.name == "copilot" then
                return true
            end
        end

        return false
    end

    local result = ""

    -- Define highlight groups with explicit background NONE to avoid inheritance
    vim.cmd("highlight CopilotEnabled guifg=" .. config.copilot.colors.enabled .. " guibg=NONE")
    vim.cmd("highlight CopilotDisabled guifg=" .. config.copilot.colors.disabled .. " guibg=NONE")

    -- Check if Copilot is loaded and enabled
    if is_copilot_enabled() then
        result = "%#CopilotEnabled#" .. config.copilot.enabled_icon .. "%*"
    else
        result = "%#CopilotDisabled#" .. config.copilot.disabled_icon .. "%*"
    end

    return result
end

function Position_component()
    local result = ""

    if config.position.show_line_column then
        local line_col = string.format("%4d:%-3d", fn.line("."), fn.col("."))
        result = result .. line_col
    end

    if config.position.show_progress then
        local total_lines = string.format("%-3d", fn.line("$"))
        result = result .. config.position.progress_icon .. " " .. total_lines
    end

    return result
end

function Statusline()
    local segments = {}

    -- Build left side components
    for _, component_name in ipairs(config.component_order.left) do
        if config.components[component_name] then
            local component
            if component_name == "mode" then
                component = Mode_component()
            elseif component_name == "file" then
                component = File_component()
            elseif component_name == "git" then
                component = Git_component()
            elseif component_name == "lsp" then
                component = Lsp_component()
            end

            if component and component ~= "" then
                table.insert(segments, component)
                table.insert(segments, config.separators.left.component)
            end
        end
    end

    -- Add spacer
    table.insert(segments, "%=")

    -- Build right side components
    for _, component_name in ipairs(config.component_order.right) do
        if config.components[component_name] then
            local component
            if component_name == "copilot" then
                component = Copilot_component()
            elseif component_name == "position" then
                component = Position_component()
            end

            if component and component ~= "" then
                table.insert(segments, config.separators.right.component)
                table.insert(segments, component)
            end
        end
    end

    return table.concat(segments)
end

-- Set up autocmd to update Git changes and redraw statusline on relevant events
cmd([[
  augroup GitStatusline
    autocmd!
    autocmd BufWritePost,FileWritePost,ShellCmdPost,VimEnter,FocusGained * lua _G.Git_changes()
    autocmd BufEnter,  * lua _G.Git_changes()
  augroup END
]])

-- Initial Git status update
_G.Git_changes()

-- Set highlights on startup
Set_highlights()

cmd([[
  augroup HighlightGroups
    autocmd!
    autocmd BufEnter, FileWritePost,VimEnter,FocusGained * lua Set_highlights()
  augroup END
]])

-- Set statusline
cmd([[ set statusline=%!luaeval('Statusline()') ]])
