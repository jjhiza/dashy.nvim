---@mod dashy.features.shortcuts Custom shortcuts management for Dashy
---@brief [[
Handles custom keyboard shortcuts and actions, with support for
icons, descriptions, and dynamic actions.
]]

local api = vim.api
local fn = vim.fn

local M = {}

-- Default configuration
M.config = {
  enabled = true,
  display_type = "grid", -- or "list"
  show_icons = true,
  show_labels = true,
  shortcut_style = "letter", -- or "number"
  default_shortcuts = {
    {
      icon = "󰈞",
      label = "New File",
      key = "n",
      action = "enew",
      description = "Create a new empty buffer",
    },
    {
      icon = "󰈢",
      label = "Find File",
      key = "f",
      action = function()
        if pcall(require, "telescope.builtin") then
          require("telescope.builtin").find_files()
        else
          vim.cmd("edit .")
        end
      end,
      description = "Search for a file",
    },
    {
      icon = "󰈬",
      label = "Recent Files",
      key = "r",
      action = function()
        if pcall(require, "telescope.builtin") then
          require("telescope.builtin").oldfiles()
        end
      end,
      description = "Open recently used files",
    },
    {
      icon = "󰊄",
      label = "Find Word",
      key = "g",
      action = function()
        if pcall(require, "telescope.builtin") then
          require("telescope.builtin").live_grep()
        end
      end,
      description = "Search for text in workspace",
    },
    {
      icon = "󰏖",
      label = "Settings",
      key = "s",
      action = function()
        if pcall(require, "telescope.builtin") then
          require("telescope.builtin").find_files({
            cwd = fn.stdpath("config"),
          })
        else
          vim.cmd("edit " .. fn.stdpath("config") .. "/init.lua")
        end
      end,
      description = "Open Neovim settings",
    },
  },
}

-- Active shortcuts
M.shortcuts = {}

-- Setup shortcuts
---@param opts table Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Initialize shortcuts
  M.shortcuts = vim.deepcopy(M.config.default_shortcuts)
  
  -- Add any custom shortcuts from config
  if opts and opts.shortcuts then
    for _, shortcut in ipairs(opts.shortcuts) do
      M.add_shortcut(shortcut)
    end
  end
  
  -- Set up autocommands for the dashboard buffer
  local group = api.nvim_create_augroup("DashyShortcuts", { clear = true })
  
  -- Set up keymaps when dashboard buffer is created
  api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "dashy",
    callback = function()
      M.setup_keymaps()
    end,
    desc = "Set up dashboard shortcuts",
  })
end

-- Add a new shortcut
---@param shortcut table Shortcut configuration
function M.add_shortcut(shortcut)
  -- Validate shortcut
  if not shortcut.key or not (shortcut.action or shortcut.command) then
    vim.notify("Invalid shortcut configuration", vim.log.levels.ERROR)
    return
  end
  
  -- Convert command to action if needed
  if shortcut.command and not shortcut.action then
    shortcut.action = function()
      vim.cmd(shortcut.command)
    end
  end
  
  -- Add default icon if needed
  if M.config.show_icons and not shortcut.icon then
    shortcut.icon = "󰌌"
  end
  
  -- Add to shortcuts list
  table.insert(M.shortcuts, shortcut)
end

-- Set up keymaps for shortcuts in dashboard buffer
function M.setup_keymaps()
  local bufnr = api.nvim_get_current_buf()
  
  -- Clear existing keymaps
  api.nvim_buf_set_keymap(bufnr, "n", "<Space>", "<NOP>", { noremap = true, silent = true })
  
  -- Set up shortcut keymaps
  for _, shortcut in ipairs(M.shortcuts) do
    local key = shortcut.key
    if M.config.shortcut_style == "number" then
      key = tostring(shortcut.number or "")
    end
    
    -- Create keymap
    api.nvim_buf_set_keymap(bufnr, "n", key, "", {
      noremap = true,
      silent = true,
      callback = function()
        -- Close dashboard before executing action
        local dashy = require("dashy")
        if dashy.close then
          dashy.close()
        end
        
        -- Execute action
        if type(shortcut.action) == "function" then
          shortcut.action()
        elseif type(shortcut.action) == "string" then
          vim.cmd(shortcut.action)
        end
      end,
      desc = shortcut.description or shortcut.label,
    })
  end
end

-- Format shortcut for display
---@param shortcut table The shortcut to format
---@return table formatted The formatted shortcut data
local function format_shortcut(shortcut)
  local formatted = {
    key = shortcut.key,
    label = shortcut.label or "",
    description = shortcut.description or "",
  }
  
  -- Add icon if enabled
  if M.config.show_icons and shortcut.icon then
    formatted.icon = shortcut.icon .. " "
  end
  
  -- Add key label based on style
  if M.config.shortcut_style == "letter" then
    formatted.key_label = "[" .. shortcut.key .. "]"
  else
    formatted.key_label = "(" .. (shortcut.number or "") .. ")"
  end
  
  return formatted
end

-- Get shortcuts data for display
---@return table Data for rendering shortcuts in the dashboard
function M.get_data()
  local items = {}
  
  -- Format shortcuts for display
  for _, shortcut in ipairs(M.shortcuts) do
    table.insert(items, format_shortcut(shortcut))
  end
  
  return {
    type = M.config.display_type,
    items = items,
    config = {
      show_icons = M.config.show_icons,
      show_labels = M.config.show_labels,
      shortcut_style = M.config.shortcut_style,
    },
  }
end

return M 