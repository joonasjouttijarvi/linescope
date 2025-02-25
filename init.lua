local M = {}

-- Default configuration
M.config = {
  colors = require("linescope.utils.colors"),
  branch_lists = require("linescope.utils.lists"),
  background = "NONE",
  auto_update = true
}

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  require("linescope.statusline")
  
  return M
end

return M 