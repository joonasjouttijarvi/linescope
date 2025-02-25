## Features

- **Mode Indication**: Displays the current Neovim mode (NORMAL, INSERT, VISUAL)
- **File Information**: Shows file icon, path, and modified status
- **LSP Diagnostics**: Indicates errors, warnings, hints, and info from language servers
- **Git Integration**: Displays branch information, added/modified/deleted/unpushed changes
- **Branch Visualization**: Custom icons and colors for different branch types (main, feature, fix, misc)
- **Copilot Status**: Shows GitHub Copilot status (supports both zbirenbaum/copilot.lua and github/copilot.vim)
- **Position Information**: Shows cursor position and total line count

## Requirements

- Neovim >= 0.10
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [vim-fugitive](https://github.com/tpope/vim-fugitive) (for git integration)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) (for file icons)

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
 {
"joonasjouttijarvi/linescope",
dependencies = {
"nvim-lua/plenary.nvim",
"tpope/vim-fugitive",
"nvim-tree/nvim-web-devicons"
},
config = function()
require("linescope").setup({
--  configuration
})
end,
},
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "joonasjouttijarvi/linescope",
  requires = {
    "nvim-lua/plenary.nvim",
    "tpope/vim-fugitive",
    "nvim-tree/nvim-web-devicons"
  },
  config = function()
    require("linescope").setup({
      --  configuration
    })
  end
}
```

## Configuration

Linescope works with minimal configuration. The following options are available:

```lua
require("linescope").setup({
  -- Global options
  background = "NONE",     -- Use "NONE" for transparent background
  auto_update = true,

  -- Component visibility
  components = {
    mode = true,
    file = true,
    git = true,
    lsp = true,
    copilot = true,
    position = true,
  },

  -- Component ordering
  component_order = {
    left = { "mode", "file", "git", "lsp" },
    right = { "copilot", "position" }
  },

  -- Mode display
  mode = {
    icons = true,
    names = {
      n = "NORMAL",
      i = "INSERT",
      v = "VISUAL",
      V = "V-LINE",
      ["\22"] = "V-BLOCK",
      c = "COMMAND",
      R = "REPLACE",
      t = "TERMINAL",
    },
  },

  -- File configuration
  file = {
    show_icon = true,
    path_type = "relative", -- "relative", "absolute", or "filename"
    max_path_length = 40,
    modified_icon = "●",
    readonly_icon = "",
  },

  -- Git configuration
  git = {
    show_branch = true,
    max_branch_length = 25,  -- Longer branch names will be truncated
    branch_icons = {
      default = "",  -- Default branch icon
      main = "",    -- Main/master branches
      feature = "󰘵",  -- Feature branches
      fix = "󰨟",     -- Bugfix branches
      misc = "󱋡",    -- Miscellaneous branches
    },
    show_status = true,
    icons = {
      added = " ",
      modified = " ",
      deleted = " ",
      renamed = "󰁕 ",
      untracked = " ?",
      staged_added = " ",
      staged_modified = " ",
      staged_deleted = " ",
      unpushed = " ",
      incoming = " ",
    }
  },

  -- LSP configuration
  lsp = {
    diagnostics_icon = "",
    error_icon = " ",
    warning_icon = " ",
    info_icon = " ",
    hint_icon = " ",
    show_message = true,
    message_length = 30,
  },

  -- Copilot status
  copilot = {
    enabled_icon = " ",
    disabled_icon = " ",
  },

  -- Position information
  position = {
    show_line_column = true,
    show_progress = true,
    progress_icon = "☰",
  },

  -- Format customization
  separators = {
    left = {
      section = " ",
      component = " ",
    },
    right = {
      section = " ",
      component = " ",
    },
  },

  -- Branch type lists - customize how branches are categorized
  branch_lists = {
    main_branches = { "main", "master", "develop" },  -- override defaults
    feature_branches = nil,
    fix_branches = nil,
    misc_branches = nil
  }
})
```
