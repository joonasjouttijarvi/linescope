local fn, cmd, api = vim.fn, vim.cmd, vim.api
local Job = require("plenary.job")
local colors = require("plugins.utils.colors")
local lists = require("plugins.statusline.utils.lists")
local status_mappings = require("plugins.statusline.utils.lists").status_mappings

local catppuccin = colors.latte
local special = colors.mocha
local mode_colors = colors.mode_colors

-- Color definitions for the statusline

local textColor = catppuccin.text
local bgColor = "NONE"
local highlightColor = catppuccin.sapphire
local feature_branch_color = catppuccin.rosewater
local fix_branch_color = catppuccin.red
local misc_branch_color = special.yellow
local detached_branch_color = special.lavender
local any_branch_color = special.sapphire

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
    errors = "",
    warnings = "",
    hints = "",
    info = "",
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

local git_status_result = ""
local last_good_status = ""

function Git_changes()
  -- check if .git directory exists
  if vim.fn.isdirectory(".git") == 0 then
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
      added = added + tonumber(a)
      deleted = deleted + tonumber(d)
    end
    result.diff = added + deleted
  end

  local function format_status(count, icon, highlight)
    return count > 0 and string.format("%s%s %d ", highlight, icon, count) or ""
  end

  function update_highlight()
    local status_parts = {
      format_status(result.unpushed, "", "%#GitUnpushed#"),
      format_status(result.added, "", "%#GitAdded#"),
      format_status(result.staged_added, "", "%#GitStagedAdded#"),
      format_status(result.modified, "", "%#GitModified#"),
      format_status(result.staged_modified, "", "%#GitStagedModified#"),
      format_status(result.deleted, "", "%#GitDeleted#"),
      format_status(result.staged_deleted, "", "%#GitStagedDeleted#"),
      format_status(result.untracked, "", "%#GitUntracked#"),
      format_status(result.renamed, "", "%#GitRenamed#"),
      format_status(result.diff, "~", "%#GitDiff#"),
      format_status(result.copied, "󰆏", "%#GitCopied#"),
      format_status(result.unmerged, "", "%#GitUnmerged#"),
      format_status(result.incoming, "", "%#GitIncoming#"),
      format_status(result.both_deleted, "", "%#GitConflict#"),
      format_status(result.added_by_us, "", "%#GitConflict#"),
      format_status(result.deleted_by_them, "", "%#GitConflict#"),
      format_status(result.added_by_them, "", "%#GitConflict#"),
      format_status(result.deleted_by_us, "", "%#GitConflict#"),
      format_status(result.both_added, "", "%#GitConflict#"),
      format_status(result.both_modified, "", "%#GitConflict#"),
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

-- Set highlight groups for Git changes
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

function Statusline()
  local branch = fn.FugitiveHead():sub(1, 25) .. (#fn.FugitiveHead() > 22 and ".." or "")
  local repo_head = fn.FugitiveHead(7)

  local modes = {
    n = "NORMAL",
    i = "INSERT",
    [""] = "VISUAL-BLOCK",
    v = "VISUAL",
    V = "VISUAL-LINE",
    R = "REPLACE",
    t = "TERMINAL",
  }

  local branch_icon = ""
  local main_branches = lists.main_branches
  local feature_branches = lists.feature_branches
  local fix_branches = lists.fix_branches
  local misc_branches = lists.misc_branches

  local branch_icons = {
    main = "%#BranchIcon#%*",
    feature = "%#BranchIcon#%*",
    fix = "%#BranchIcon#%*",
    misc = "%#BranchIcon#%*",
    any = "%#BranchIcon#%*",
    empty = "%#BranchIcon#󱓌 %*" .. repo_head .. " %*",
  }

  if branch and #branch > 0 then
    if vim.tbl_contains(main_branches, branch) then
      vim.cmd("highlight BranchIcon guifg=" .. highlightColor)
      branch_icon = branch_icons.main
    elseif branch_starts_with_prefix(branch, feature_branches) then
      vim.cmd("highlight BranchIcon guifg=" .. feature_branch_color)
      branch_icon = branch_icons.feature
    elseif branch_starts_with_prefix(branch, fix_branches) then
      vim.cmd("highlight BranchIcon guifg=" .. fix_branch_color)
      branch_icon = branch_icons.fix
    elseif branch_starts_with_prefix(branch, misc_branches) then
      vim.cmd("highlight BranchIcon guifg=" .. misc_branch_color)
      branch_icon = branch_icons.misc
    else
      vim.cmd("highlight BranchIcon guifg=" .. any_branch_color)
      branch_icon = branch_icons.any
    end
  else
    branch_icon = branch_icons.empty
    vim.cmd("highlight BranchIcon guifg=" .. detached_branch_color)
    branch_icon = branch_icons.empty
  end

  local copilot_icon = ""
  local function set_copilot_icon_and_color()
    if vim.fn["copilot#Enabled"]() == 1 then
      vim.cmd("highlight CopilotIcon guifg=" .. detached_branch_color)
      copilot_icon = ""
    else
      copilot_icon = ""
    end
  end

  -- Call the function to set the icon and color
  set_copilot_icon_and_color()

  -- statusline text color
  vim.cmd("highlight StatusLine guifg=" .. textColor .. " guibg=" .. bgColor)

  -- current mode
  local mode = api.nvim_get_mode().mode
  local modeColor = mode_colors[mode] or textColor
  local warnings = Lsp_info()
  local icon = File_icon()
  mode = modes[mode] or mode:upper()

  -- Set mode color
  vim.cmd("highlight ModeHighlight guifg=" .. modeColor .. " guibg=" .. bgColor)

  -- Reserve space for line number and column number
  local total_lines = string.format("%-3d", fn.line("$"))
  local line_col = string.format("%4d:%-3d", fn.line("."), fn.col("."))
  local path = string.format("%-4s", fn.expand("%:p:~:h"))

  return "%#ModeHighlight#"
      .. mode
      .. "%* "
      .. path
      .. " "
      .. icon
      .. "%m%="
      .. warnings
      .. git_status_result
      .. " "
      .. branch_icon
      .. " "
      .. branch
      .. "  "
      .. copilot_icon
      .. "  "
      .. line_col
      .. total_lines
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

cmd([[ set statusline=%!luaeval('Statusline()') ]])

cmd([[
  augroup HighlightGroups
    autocmd!
    autocmd BufEnter, FileWritePost,VimEnter,FocusGained * lua set_highlights()
  augroup END
]])
