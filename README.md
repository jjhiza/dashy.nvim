# dashy.nvim

A modern, fast, and beautiful dashboard for Neovim that provides quick access to your projects, sessions, and recent files.

![dashy.nvim screenshot](screenshot.png)

## Features

- 🚀 **Fast and Modern**: Built with performance in mind using modern Neovim APIs
- 🎨 **Beautiful UI**: Clean and modern interface with customizable themes
- 📁 **Project Management**: Quick access to your projects with search and filtering
- 💾 **Session Management**: Save and restore your Neovim sessions
- 📝 **Recent Files**: Access your recently opened files with search
- ⚡ **Custom Shortcuts**: Add your own shortcuts and commands
- 🎯 **Smart Search**: Fuzzy finder integration for quick navigation
- 🔧 **Highly Customizable**: Configure every aspect of the dashboard

## Requirements

- Neovim >= 0.10.0
- A Nerd Font (optional, but recommended for icons)
- [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) (optional, for file icons)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "jjhiza/dashy.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("dashy").setup({
      -- your configuration here
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "jjhiza/dashy.nvim",
  requires = "nvim-tree/nvim-web-devicons",
  config = function()
    require("dashy").setup({
      -- your configuration here
    })
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'jjhiza/dashy.nvim'
Plug 'nvim-tree/nvim-web-devicons'
```

Then in your `init.lua` or `init.vim`:

```lua
require("dashy").setup({
  -- your configuration here
})
```

## Configuration

The plugin can be configured by passing a table to the setup function. Here's an example with all available options:

```lua
require("dashy").setup({
  -- Theme configuration
  theme = {
    -- Background color of the dashboard
    bg = "#1a1b26",
    -- Foreground color for text
    fg = "#a9b1d6",
    -- Accent color for highlights
    accent = "#7aa2f7",
    -- Border color
    border = "#24283b",
  },

  -- Header configuration
  header = {
    -- Text to display in the header
    text = "Welcome to Neovim",
    -- Highlight group for the header
    highlight = "DashboardHeader",
  },

  -- Footer configuration
  footer = {
    -- Text to display in the footer
    text = "Press ? for help",
    -- Highlight group for the footer
    highlight = "DashboardFooter",
  },

  -- Project section configuration
  projects = {
    -- Directory to scan for projects
    directory = "~/Projects",
    -- Maximum number of projects to display
    max_items = 10,
    -- File patterns to ignore
    ignore_patterns = { ".git", "node_modules" },
  },

  -- Session configuration
  sessions = {
    -- Directory to store sessions
    directory = "~/.local/share/nvim/sessions",
    -- Maximum number of sessions to display
    max_items = 10,
  },

  -- Recent files configuration
  recent_files = {
    -- Maximum number of recent files to display
    max_items = 10,
    -- File patterns to ignore
    ignore_patterns = { ".git", "node_modules" },
  },

  -- Shortcuts configuration
  shortcuts = {
    -- List of shortcuts to display
    items = {
      { key = "e", desc = "New file", cmd = "enew" },
      { key = "q", desc = "Quit", cmd = "qa" },
      { key = "w", desc = "Save", cmd = "w" },
    },
  },

  -- Key mappings
  mappings = {
    -- Key to open the dashboard
    open = "<leader>d",
    -- Key to close the dashboard
    close = "q",
    -- Key to refresh the dashboard
    refresh = "r",
    -- Key to toggle help
    help = "?",
  },
})
```

## Usage

### Opening the Dashboard

By default, you can open the dashboard using `<leader>d`. You can customize this key mapping in the configuration.

### Navigation

- Use `j` and `k` to navigate through items
- Press `Enter` to select an item
- Press `q` to close the dashboard
- Press `?` to toggle help

### Sections

#### Projects
- Displays your recent projects
- Use `/` to search through projects
- Press `Enter` to open a project

#### Sessions
- Shows your saved Neovim sessions
- Press `Enter` to load a session
- Press `d` to delete a session

#### Recent Files
- Lists your recently opened files
- Use `/` to search through files
- Press `Enter` to open a file

#### Shortcuts
- Quick access to common commands
- Press `Enter` to execute a shortcut

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [dashboard.nvim](https://github.com/glepnir/dashboard-nvim)
- Icons provided by [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)