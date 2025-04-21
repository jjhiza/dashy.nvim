---@mod dashy.keymaps Keymap management for Dashy
---@brief [[
-- Provides keymap configuration and management for the Dashy dashboard.
-- Handles default keybindings, user-configurable mappings, and shortcut display.
-- ]]

-- Module definition
---@class DashyKeymaps
local M = {}

-- Store local references to Vim APIs for performance
local api = vim.api
local keymap = vim.keymap

-- Get safe require from main module
local dashy = require("dashy")
local safe_require = dashy.safe_require

-- Store active keymaps to allow for cleanup
---@type table<number, string[]>
local active_mappings = {}

-- Define keymap action types
---@alias DashyKeymapAction
---| "quit" # Close the dashboard
---| "open_file" # Open a file
---| "find_files" # Find files
---| "find_recent" # Find recent files
---| "new_file" # Create a new file
---| "find_projects" # Find projects
---| "load_session" # Load a session
---| "browse_dotfiles" # Browse dotfiles
---| "check_health" # Run health check
---| "update_plugins" # Update plugins
---| "settings" # Open settings
---| "help" # Open help
---| "custom" # Custom action

-- Define keymap shortcut display types
---@alias DashyShortcutType
---| "letter" # Letter-based shortcuts (a, b, c, ...)
---| "number" # Number-based shortcuts (1, 2, 3, ...)

-- Define keymap shortcut display styles
---@alias DashyShortcutStyle
---| "icon" # Icon-based shortcuts
---| "text" # Text-based shortcuts

---@class DashyKeymapDefinition
---@field key string The key to map
---@field action DashyKeymapAction The action to perform
---@field desc string Description of the mapping
---@field label string|nil Label to display in shortcut (defaults to key)
---@field shortcut_type DashyShortcutType|nil Type of shortcut (letter or number)
---@field shortcut_style DashyShortcutStyle|nil Style of shortcut (icon or text)
---@field shortcut_icon string|nil Icon to display for the shortcut (if using icon style)
---@field callback function|nil Custom callback function for the action
---@field opts table|nil Additional options for the keymap

-- Default keymaps with descriptive labels
---@type DashyKeymapDefinition[]
local default_keymaps = {
  {
    key = "q",
    action = "quit",
    desc = "Close dashboard",
    label = "q",
  },
  {
    key = "e",
    action = "new_file",
    desc = "New file",
    label = "e",
  },
  {
    key = "f",
    action = "find_files",
    desc = "Find files",
    label = "f",
  },
  {
    key = "r",
    action = "find_recent",
    desc = "Recent files",
    label = "r",
  },
  {
    key = "p",
    action = "find_projects",
    desc = "Projects",
    label = "p",
  },
  {
    key = "s",
    action = "load_session",
    desc = "Sessions",
    label = "s",
  },
  {
    key = "u",
    action = "update_plugins",
    desc = "Update plugins",
    label = "u",
  },
  {
    key = "?",
    action = "help",
    desc = "Help",
    label = "?",
  },
  {
    key = "h",
    action = "check_health",
    desc = "Health check",
    label = "h",
  },
  {
    key = "<Esc>",
    action = "quit",
    desc = "Close dashboard",
    label = nil, -- Hidden from shortcut display
  },
}

-- Number-based default keymaps alternative
---@type DashyKeymapDefinition[]
local number_keymaps = {
  {
    key = "1",
    action = "new_file",
    desc = "New file",
    label = "1",
  },
  {
    key = "2",
    action = "find_files",
    desc = "Find files",
    label = "2",
  },
  {
    key = "3",
    action = "find_recent",
    desc = "Recent files",
    label = "3",
  },
  {
    key = "4",
    action = "find_projects",
    desc = "Projects",
    label = "4",
  },
  {
    key = "5",
    action = "load_session",
    desc = "Sessions",
    label = "5",
  },
  {
    key = "6",
    action = "update_plugins",
    desc = "Update plugins",
    label = "6",
  },
  {
    key = "7",
    action = "help",
    desc = "Help",
    label = "7",
  },
  {
    key = "8",
    action = "check_health",
    desc = "Health check",
    label = "8",
  },
  {
    key = "q",
    action = "quit",
    desc = "Close dashboard",
    label = "q",
  },
  {
    key = "<Esc>",
    action = "quit",
    desc = "Close dashboard",
    label = nil, -- Hidden from shortcut display
  },
}

-- Action handler functions
local actions = {
  -- Close the dashboard
  quit = function()
    local layout = safe_require("dashy.layout")
    if layout then
      layout.destroy()
    end
  end,

  -- Open a new file
  new_file = function()
    local layout = safe_require("dashy.layout")
    if layout then
      layout.destroy()
      vim.cmd("enew")
    end
  end,

  -- Find files using Telescope if available, otherwise use builtin finder
  find_files = function()
    local has_telescope, telescope = pcall(require, "telescope.builtin")
    if has_telescope then
      local layout = safe_require("dashy.layout")
      if layout then
        layout.destroy()
      end
      telescope.find_files()
    else
      vim.cmd("edit .")
    end
  end,

  -- Find recent files using Telescope if available
  find_recent = function()
    local has_telescope, telescope = pcall(require, "telescope.builtin")
    if has_telescope then
      local layout = safe_require("dashy.layout")
      if layout then
        layout.destroy()
      end
      telescope.oldfiles()
    else
      vim.cmd("browse oldfiles")
    end
  end,

  -- Find projects using project.nvim if available
  find_projects = function()
    local has_project = pcall(require, "project_nvim")
    if has_project and pcall(require, "telescope") then
      local layout = safe_require("dashy.layout")
      if layout then
        layout.destroy()
      end
      require("telescope").extensions.projects.projects({})
    else
      vim.notify(
        "project.nvim or telescope not found. Please install them for project management.",
        vim.log.levels.WARN
      )
    end
  end,

  -- Load session using auto-session or persisted.nvim if available
  load_session = function()
    local layout = safe_require("dashy.layout")
    if layout then
      layout.destroy()
    end

    local has_auto_session = pcall(require, "auto-session")
    local has_persisted = pcall(require, "persisted")
    local has_telescope = pcall(require, "telescope")

    if has_auto_session and has_telescope then
      require("auto-session.session-lens").search_session()
    elseif has_persisted and has_telescope then
      require("telescope").extensions.persisted.persisted({})
    else
      vim.notify(
        "No session management plugin found. Please install auto-session or persisted.nvim.",
        vim.log.levels.WARN
      )
    end
  end,

  -- Update plugins using the plugin manager if available
  update_plugins = function()
    local layout = safe_require("dashy.layout")
    if layout then
      layout.destroy()
    end

    -- Try different plugin managers
    if vim.fn.exists(":Lazy") == 2 then
      vim.cmd("Lazy update")
    elseif vim.fn.exists(":PackerUpdate") == 2 then
      vim.cmd("PackerUpdate")
    else
      vim.notify("No supported plugin manager found.", vim.log.levels.WARN)
    end
  end,

  -- Open help documentation
  help = function()
    local layout = safe_require("dashy.layout")
    if layout then
      layout.destroy()
    end
    vim.cmd("help dashy.nvim")
  end,

  -- Run health check
  check_health = function()
    local layout = safe_require("dashy.layout")
    if layout then
      layout.destroy()
    end
    vim.cmd("checkhealth dashy")
  end,

  -- Custom action (handled by user callback)
  custom = function(callback)
    if type(callback) == "function" then
      callback()
    else
      vim.notify("No callback provided for custom action", vim.log.levels.ERROR)
    end
  end,
}

-- Execute a keymap action
---@param action DashyKeymapAction The action to execute
---@param callback function|nil Custom callback for custom actions
local function execute_action(action, callback)
  if actions[action] then
    if action == "custom" then
      actions[action](callback)
    else
      actions[action]()
    end
  else
    vim.notify("Unknown action: " .. action, vim.log.levels.ERROR)
  end
end

-- Create a keymap for a specific buffer
---@param buf_id number Buffer ID to map keys in
---@param key string Key to map
---@param action DashyKeymapAction Action to perform
---@param desc string Description for the mapping
---@param callback function|nil Custom callback function
---@param opts table|nil Additional options
local function create_buffer_keymap(buf_id, key, action, desc, callback, opts)
  opts = vim.tbl_extend("force", { silent = true, noremap = true, nowait = true, desc = desc }, opts or {})

  -- Register the mapping
  keymap.set("n", key, function()
    execute_action(action, callback)
  end, vim.tbl_extend("force", opts, { buffer = buf_id }))

  -- Store for cleanup
  if not active_mappings[buf_id] then
    active_mappings[buf_id] = {}
  end
  table.insert(active_mappings[buf_id], key)
end

-- Get keymap definitions based on configuration
---@return DashyKeymapDefinition[]
local function get_keymap_definitions()
  local config = safe_require("dashy.config")
  if not config then
    return default_keymaps
  end

  -- Check shortcut type configuration
  local shortcut_type = config.get("shortcut_type") or "letter"
  if shortcut_type == "number" then
    return number_keymaps
  else
    return default_keymaps
  end
end

-- Get user-defined keymaps from configuration
---@return DashyKeymapDefinition[]
local function get_user_keymaps()
  local config = safe_require("dashy.config")
  if not config then
    return {}
  end

  local user_keymaps = config.get("keymaps") or {}
  return user_keymaps
end

-- Merge default keymaps with user-defined keymaps
---@return DashyKeymapDefinition[]
local function merge_keymaps()
  local keymaps = get_keymap_definitions()
  local user_keymaps = get_user_keymaps()

  -- Create a map of default keymaps by key for easy lookup
  local keymaps_by_key = {}
  for _, keymap in ipairs(keymaps) do
    keymaps_by_key[keymap.key] = true
  end

  -- Add user keymaps that don't override defaults
  for _, user_keymap in ipairs(user_keymaps) do
    -- If key already exists, replace the default mapping
    local existing_idx = nil
    for idx, keymap in ipairs(keymaps) do
      if keymap.key == user_keymap.key then
        existing_idx = idx
        break
      end
    end

    if existing_idx then
      keymaps[existing_idx] = user_keymap
    else
      table.insert(keymaps, user_keymap)
    end
  end

  return keymaps
end

-- Setup keymaps for the dashboard buffer
---@param buf_id number Buffer ID to set up keymaps for
---@return boolean success Whether setup was successful
function M.setup(buf_id)
  if not api.nvim_buf_is_valid(buf_id) then
    vim.notify("Invalid buffer for keymap setup", vim.log.levels.ERROR)
    return false
  end

  -- Clear any existing mappings for this buffer
  M.clear(buf_id)

  -- Get and merge keymaps
  local keymaps = merge_keymaps()

  -- Set up each keymap
  for _, keymap_def in ipairs(keymaps) do
    create_buffer_keymap(
      buf_id,
      keymap_def.key,
      keymap_def.action,
      keymap_def.desc,
      keymap_def.callback,
      keymap_def.opts
    )
  end

  return true
end

-- Clear all keymaps for a buffer
---@param buf_id number Buffer ID to clear keymaps for
---@return boolean success Whether cleanup was successful
function M.clear(buf_id)
  if not api.nvim_buf_is_valid(buf_id) then
    return false
  end

  -- Clear all active mappings for this buffer
  if active_mappings[buf_id] then
    for _, key in ipairs(active_mappings[buf_id]) do
      pcall(api.nvim_buf_del_keymap, buf_id, "n", key)
    end
    active_mappings[buf_id] = {}
  end

  return true
end

-- Get all active keymaps for shortcut display
---@return DashyKeymapDefinition[] keymaps List of active keymaps
function M.get_display_keymaps()
  -- Get and merge keymaps
  local keymaps = merge_keymaps()
  
  -- Filter out keymaps that shouldn't be displayed (no label)
  local display_keymaps = {}
  for _, keymap in ipairs(keymaps) do
    if keymap.label then
      table.insert(display_keymaps, keymap)
    end
  end
  
  return display_keymaps
end

-- Generate shortcut text for display
---@param keymap DashyKeymapDefinition The keymap definition
---@return string shortcut_text The formatted shortcut text
---@return string shortcut_icon The icon to display (if available)
function M.generate_shortcut_text(keymap)
  local config = safe_require("dashy.config")
  local shortcut_style = (config and config.get("shortcut_style")) or "text"
  local shortcut_type = (config and config.get("shortcut_type")) or "letter"
  
  -- Use the keymap's specific settings if provided
  if keymap.shortcut_style then
    shortcut_style = keymap.shortcut_style
  end
  if keymap.shortcut_type then
    shortcut_type = keymap.shortcut_type
  end
  
  local label = keymap.label or keymap.key
  local icon = ""
  
  -- Get icon for the action if using icon style
  if shortcut_style == "icon" then
    icon = keymap.shortcut_icon or M.get_icon_for_action(keymap.action)
  end
  
  return label, icon
end

-- Get appropriate icon for an action
---@param action DashyKeymapAction The action to get an icon for
---@return string icon The icon to use for the action (empty string if not available)
function M.get_icon_for_action(action)
  -- Check if web-devicons is available
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if not has_devicons then
    return ""
  end
  
  -- Map actions to appropriate file types/icons
  local action_to_icon = {
    new_file = "file",
    find_files = "finder",
    find_recent = "history",
    find_projects = "project",
    load_session = "session",
    update_plugins = "package",
    help = "help",
    check_health = "diagnostic",
    quit = "close",
    settings = "settings",
    custom = "code",
  }
  
  -- Map actions to file extensions for devicons
  local action_to_ext = {
    new_file = "txt",
    find_files = "finder",
    find_recent = "old",
    find_projects = "git",
    load_session = "session",
    update_plugins = "lock",
    help = "help",
    check_health = "health",
    quit = "exit",
    settings = "json",
    custom = "lua",
  }
  
  -- Try to get icon from devicons
  local ext = action_to_ext[action] or "txt"
  local icon, _ = devicons.get_icon(ext, { default = true })
  
  -- Fallback to UTF-8 icons if devicons didn't provide one
  if not icon or icon == "" then
    local utf8_icons = {
      new_file = "󰈔 ",
      find_files = "󰮗 ",
      find_recent = " ",
      find_projects = "󰏓 ",
      load_session = "󱂷 ",
      update_plugins = "󰚰 ",
      help = "󰋗 ",
      check_health = "󰷛 ",
      quit = "󰩈 ",
      settings = "󰒓 ",
      custom = "󰘦 ",
    }
    
    icon = utf8_icons[action] or "󰦮 "
  end
  
  return icon
end

-- Format shortcut display for a keymap
---@param keymap DashyKeymapDefinition The keymap definition
---@return string display_text The formatted display text
function M.format_shortcut_display(keymap)
  local label, icon = M.generate_shortcut_text(keymap)
  local config = safe_require("dashy.config")
  local shortcut_style = (config and config.get("shortcut_style")) or "text"
  
  -- Create display text based on style
  local display_text = ""
  
  if shortcut_style == "icon" and icon and icon ~= "" then
    display_text = string.format("%s %s", icon, keymap.desc)
  else
    display_text = string.format("%s - %s", label, keymap.desc)
  end
  
  return display_text
end

-- Get formatted shortcut display text for all visible keymaps
---@return string[] shortcut_texts List of formatted shortcut texts
function M.get_shortcut_display_texts()
  local keymaps = M.get_display_keymaps()
  local texts = {}
  
  for _, keymap in ipairs(keymaps) do
    table.insert(texts, M.format_shortcut_display(keymap))
  end
  
  return texts
end

-- Group keymaps for organized display (e.g., in columns)
---@param columns number Number of columns to organize into
---@return table grouped_keymaps Keymaps organized into columns
function M.group_keymaps_for_display(columns)
  local keymaps = M.get_display_keymaps()
  local grouped = {}
  
  local items_per_column = math.ceil(#keymaps / columns)
  
  for i = 1, columns do
    grouped[i] = {}
    local start_idx = (i - 1) * items_per_column + 1
    local end_idx = math.min(i * items_per_column, #keymaps)
    
    for j = start_idx, end_idx do
      if keymaps[j] then
        table.insert(grouped[i], keymaps[j])
      end
    end
  end
  
  return grouped
end

-- Generate shortcut section content for the dashboard
---@param columns number Number of columns to organize shortcuts into
---@return string[] content Lines of content for the shortcuts section
function M.generate_shortcut_section(columns)
  columns = columns or 2 -- Default to 2 columns
  
  local grouped_keymaps = M.group_keymaps_for_display(columns)
  local max_lengths = {}
  local content = {}
  
  -- Calculate maximum length of each column for alignment
  for col = 1, columns do
    max_lengths[col] = 0
    if grouped_keymaps[col] then
      for _, keymap in ipairs(grouped_keymaps[col]) do
        local display_text = M.format_shortcut_display(keymap)
        max_lengths[col] = math.max(max_lengths[col], vim.fn.strdisplaywidth(display_text))
      end
    end
  end
  
  -- Determine how many rows we need
  local max_rows = 0
  for col = 1, columns do
    if grouped_keymaps[col] then
      max_rows = math.max(max_rows, #grouped_keymaps[col])
    end
  end
  
  -- Generate rows with properly padded columns
  for row = 1, max_rows do
    local line = ""
    
    for col = 1, columns do
      if grouped_keymaps[col] and grouped_keymaps[col][row] then
        local keymap = grouped_keymaps[col][row]
        local display_text = M.format_shortcut_display(keymap)
        local padding = string.rep(" ", max_lengths[col] - vim.fn.strdisplaywidth(display_text) + 4)
        
        line = line .. display_text .. padding
      end
    end
    
    table.insert(content, line)
  end
  
  return content
end

-- Add keymaps to the dashboard theme content
---@param content table The theme content table with header, center, and footer
---@return table updated_content The updated content with shortcuts
function M.add_shortcuts_to_content(content)
  if not content then
    return content
  end
  
  -- Generate shortcut content
  local shortcut_content = M.generate_shortcut_section(2)
  
  -- Add spacing before shortcuts
  table.insert(content.center, "")
  
  -- Add shortcut section to center content
  for _, line in ipairs(shortcut_content) do
    table.insert(content.center, line)
  end
  
  return content
end

-- Return the module
return M

