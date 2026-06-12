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

Optional:

- [vim-fugitive](https://github.com/tpope/vim-fugitive) or [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) (faster branch updates; linescope falls back to calling git directly)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) (for file icons)

Run `:checkhealth linescope` to verify your setup.

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

Linescope configs.

```lua
require("linescope").setup({
    background = "...",
    auto_update = true|false,

    components = { mode, file, git, lsp, copilot, position },
    component_order = { left = {...}, right = {...} },

    mode = { names, colors },
    file = { show_icon, show_path, path_type, max_path_length, readonly_icon, modified_icon },
    git = { show_branch, max_branch_length, branch_icon, show_status, icons },
    lsp = { error_icon, warning_icon, info_icon, hint_icon },
    copilot = { enabled_icon, disabled_icon, colors },
    position = { show_line_column, show_progress, progress_icon },
    separators = { left = {...}, right = {...} },
})
```
