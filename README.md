# Linescope 
statusline plugin for neovim

## Features

- Mode Indication: <br>
  Displays the current Neovim mode (e.g., NORMAL, INSERT, VISUAL. etc.).
- File Information: <br> Shows the current file's icon, path, and modified status.
- LSP Diagnostics: <br> Indicates errors, warnings, hints, and info from the language server.
- Git Status: <br> Displays information about added, modified, deleted, and unpushed changes, as well as branch name and status.
- Branch Icon and Coloring:<br> Highlights different types of branches (main, feature, fix, misc) with distinct colors and icons.
- Copilot Status:<br> Shows the status of GitHub copilot. (zbirenbaum/copilot.lua, and github/copilot.vim)
- Line and Column Numbers: <br>Indicates the current cursor position and total line count.

### Prerequisites

- Neovim >= 0.10
- Plenary.nvim
- Fugitive (for git integration)
- nvim-web-devicons

### Installation

Use plugin manager to install the plugin
 
 Add to config

   ```lua
   require('statusline')

   ```

### Configuration

#### Color and Icon Customization

- Colors: Customize the colors in the script by modifying the colors table. 
- Icons: Change icons in the diagnosticSigns and branch_icons tables.

#### Branch Naming

- Main, Feature, Fix, and Misc Branches: Customize the branch prefixes in the statusline.utils.lists module.
  The statusline updates automatically on relevant events, such as file changes, entering a buffer, and Git operations. Manually refresh the statusline using the :redrawstatus command.

