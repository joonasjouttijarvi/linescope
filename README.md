# Linescope statusline for nvim 

## Features
- Mode Indication: Displays the current Neovim mode (e.g., NORMAL, INSERT, VISUAL).
- File Information: Shows the current file's icon, path, and modified status.
- LSP Diagnostics: Indicates errors, warnings, hints, and info from the language server.
- Git Status: Displays information about added, modified, deleted, and unpushed changes, as well as branch name and status.
- Branch Icon and Coloring: Highlights different types of branches (main, feature, fix, misc) with distinct colors and icons.
- Copilot Status: Shows the status of GitHub Copilot if enabled.
- Line and Column Numbers: Indicates the current cursor position and total line count.
- Setup
 ### Prerequisites
- Neovim >= 0.10
- Plenary.nvim
- nvim-web-devicons

 ### Installation

1. Clone or download the repository.

  Save the script to your Neovim configuration directory, typically located at ~/.config/nvim/lua/statusline.lua.

2. Add the following line to your init.vim or init.lua file.
    
      ```lua
      require('statusline')
      
      ```

### Configuration
 #### Color and Icon Customization
 - Colors: Customize the colors in the script by modifying the colors table.
 - Icons: Change icons in the diagnosticSigns and branch_icons tables to suit your preferences.
#### Branch Naming
- Main, Feature, Fix, and Misc Branches: Customize the branch prefixes in the statusline.utils.lists module to match your Git workflow.
Usage
The statusline updates automatically on relevant events, such as file changes, entering a buffer, and Git operations. You can manually refresh the statusline using the :redrawstatus command.

 ### License
This script is released under the MIT License.
