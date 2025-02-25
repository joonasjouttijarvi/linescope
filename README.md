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

Linescope works with minimal configuration. The following defaults:

```lua
require("linescope").setup({
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
        path_type = "relative",
        max_path_length = 40,
        readonly_icon = "",
    },

    git = {
        show_branch = true,
        max_branch_length = 20,
        branch_icon = "",
        show_status = true,
        icons = {
            added = "",
            modified = "",
            deleted = "",
            renamed = "",
            untracked = "?",
            staged_added = "",
            staged_modified = "",
            staged_deleted = "",
            unpushed = "⇡",
            incoming = "⇣",
        },
    },

    lsp = {
        diagnostics_icon = "",
        error_icon = "",
        warning_icon = "",
        info_icon = "",
        hint_icon = "",
        show_message = true,
        message_length = 30,
    },

    copilot = {
        enabled_icon = "",
        disabled_icon = "",
        colors = {
            enabled = "#6c6f85",
            disabled = "#6E738D",
        }
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
  -- Branch type lists - customize how branches are categorized
  branch_lists = {
    main_branches = { "main", "master" },  -- override defaults
    feature_branches = nil,
    fix_branches = nil,
    misc_branches = nil
  }
})
```
