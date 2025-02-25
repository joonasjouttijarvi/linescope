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
-- Optional configuration
-- background = "NONE", -- Use "NONE" for transparent background
-- auto_update = true, -- Auto update statusline on events
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
      -- Optional configuration
    })
  end
}
```

## Configuration

Linescope works with minimal configuration, but can be customized:

```lua
require("linescope").setup({
  background = "#1a1b26", -- Custom background color or "NONE" for transparent
  auto_update = true,     -- Auto update statusline on events
})
```
