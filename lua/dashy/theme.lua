---@mod dashy.theme Theme management for Dashy
---@brief [[
-- Provides theme management for the Dashy dashboard.
-- Includes a default theme and utilities for theme switching.
-- ]]

local api = vim.api

-- Module definition
---@class DashyTheme
local M = {}

-- Get the safe require utility from the main module
local safe_require = require("dashy").safe_require

-- Default theme colors
local default_colors = {
  bg = "#1a1b26",
  fg = "#a9b1d6",
  accent = "#7aa2f7",
  border = "#24283b",
  success = "#9ece6a",
  warning = "#e0af68",
  error = "#f7768e",
  info = "#7aa2f7",
}

-- Current theme
local current_theme = "default"

-- Get current theme name
---@return string
function M.get_current_theme()
  return current_theme
end

-- Set current theme
---@param theme_name string Theme name
function M.set_current_theme(theme_name)
  current_theme = theme_name
  local highlights = safe_require("dashy.highlights")
  if highlights then
    highlights.update_theme(theme_name)
  end
end

-- Get theme colors
---@param theme_name? string Optional theme name
---@return table
function M.get_colors(theme_name)
  theme_name = theme_name or current_theme
  
  -- Try to load theme module
  local theme_module = safe_require("dashy.theme." .. theme_name)
  if theme_module and theme_module.get_colors then
    return theme_module.get_colors()
  end
  
  -- Return default colors if theme module not found
  return default_colors
end

-- Apply theme to buffer
---@param buf_id number Buffer ID
---@param theme_name? string Optional theme name
function M.apply_to_buffer(buf_id, theme_name)
  theme_name = theme_name or current_theme
  
  -- Try to load theme module
  local theme_module = safe_require("dashy.theme." .. theme_name)
  if not theme_module then
    vim.notify("Failed to load theme module: " .. theme_name, vim.log.levels.ERROR)
    return
  end
  
  -- Set up highlights first
  local highlights = safe_require("dashy.highlights")
  if highlights then
    highlights.setup({ theme = theme_module.get_colors() })
  end
  
  -- Get theme content and apply it
  if theme_module.get_content then
    local win_id = api.nvim_get_current_win()
    local content = theme_module.get_content(buf_id, win_id)
    if content then
      -- Set buffer-specific highlights before content
      local ns_id = vim.api.nvim_create_namespace("dashy_theme")
      api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)
      
      -- Apply background color
      api.nvim_buf_set_option(buf_id, "winhl", "Normal:DashboardNormal,EndOfBuffer:DashboardEndOfBuffer")
      
      -- Apply border highlights if window exists
      if win_id then
        api.nvim_win_set_option(win_id, "winhl", "Normal:DashboardNormal,EndOfBuffer:DashboardEndOfBuffer")
      end
      
      -- Apply theme highlights
      if theme_module.apply_highlights then
        theme_module.apply_highlights(buf_id, content.header)
      end
      
      -- Combine all content
      local lines = {}
      
      -- Get window width for centering
      local win_width = api.nvim_win_get_width(win_id)
      
      -- Calculate vertical spacing for absolutely centered content
      local header_height = #content.header
      local center_height = #content.center
      local footer_height = #content.footer
      local total_content_height = header_height + center_height + footer_height + 2 -- +2 for spacers
      local win_height = api.nvim_win_get_height(win_id)
      local top_padding = math.floor((win_height - total_content_height) / 2)
      
      -- Add top padding
      for i = 1, top_padding do
        table.insert(lines, "")
      end
      
      -- Center header content
      for _, line in ipairs(content.header) do
        local centered_line = M.center_line(line, win_width)
        table.insert(lines, centered_line)
      end
      
      -- Add a spacer
      table.insert(lines, "")
      
      -- Center menu items with consistent left alignment
      local menu_items = content.center
      local menu_item_width = 0
      
      -- Calculate maximum width of menu items
      for _, line in ipairs(menu_items) do
        menu_item_width = math.max(menu_item_width, vim.fn.strdisplaywidth(line))
      end
      
      -- Calculate padding for perfect center alignment
      local center_padding = math.floor((win_width - menu_item_width) / 2)
      
      -- Apply consistent padding to all menu items
      for _, line in ipairs(menu_items) do
        local padded_line = string.rep(" ", center_padding) .. line
        table.insert(lines, padded_line)
      end
      
      -- Add a spacer
      table.insert(lines, "")
      
      -- Center footer content
      for _, line in ipairs(content.footer) do
        local centered_line = M.center_line(line, win_width)
        table.insert(lines, centered_line)
      end
      
      -- Add bottom padding if needed to balance out the vertical centering
      local current_height = #lines
      local bottom_padding = win_height - current_height
      if bottom_padding > 0 then
        for i = 1, bottom_padding do
          table.insert(lines, "")
        end
      end
      
      -- Set buffer content
      api.nvim_buf_set_option(buf_id, "modifiable", true)
      api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      api.nvim_buf_set_option(buf_id, "modifiable", false)
    else
      vim.notify("No content received from theme module", vim.log.levels.ERROR)
    end
  else
    vim.notify("Theme module does not have get_content function", vim.log.levels.ERROR)
  end
end

-- Center a line of text in the given width
---@param line string The line to center
---@param width number The width to center within
---@return string The centered line
function M.center_line(line, width)
  local line_length = vim.fn.strdisplaywidth(line)
  local padding = math.floor((width - line_length) / 2)
  if padding < 0 then padding = 0 end
  return string.rep(" ", padding) .. line
end

-- Initialize theme system
---@param config table Configuration options
function M.setup(config)
  -- Set initial theme
  if config.theme then
    current_theme = config.theme
    M.set_current_theme(config.theme)
  end
  
  -- Setup highlights
  local highlights = safe_require("dashy.highlights")
  if highlights then
    highlights.setup(config)
  end
end

return M 