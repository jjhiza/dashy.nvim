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
    return
  end
  
  -- Get theme content and apply it
  local content = nil
  if theme_module.get_content then
    content = theme_module.get_content(buf_id, api.nvim_get_current_win())
    if content then
      -- Combine all content
      local lines = {}
      
      -- Add header
      for _, line in ipairs(content.header) do
        table.insert(lines, line)
      end
      
      -- Add center content
      for _, line in ipairs(content.center) do
        table.insert(lines, line)
      end
      
      -- Add footer
      for _, line in ipairs(content.footer) do
        table.insert(lines, line)
      end
      
      -- Set buffer content
      api.nvim_buf_set_option(buf_id, "modifiable", true)
      api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      api.nvim_buf_set_option(buf_id, "modifiable", false)
      
      -- Apply theme highlights
      if theme_module.apply_highlights then
        theme_module.apply_highlights(buf_id, lines)
      end
    end
  end
  
  -- Set buffer-specific highlights
  local ns_id = api.nvim_get_namespace("dashy_theme")
  api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)
  
  -- Apply background color
  api.nvim_buf_set_option(buf_id, "winhl", string.format("Normal:DashboardNormal,EndOfBuffer:DashboardEndOfBuffer"))
  
  -- Apply border highlights if window exists
  local win_id = api.nvim_get_current_win()
  if win_id then
    api.nvim_win_set_option(win_id, "winhl", string.format("Normal:DashboardNormal,EndOfBuffer:DashboardEndOfBuffer"))
  end
end

-- Initialize theme system
---@param config table Configuration options
function M.setup(config)
  -- Set initial theme
  if config.theme then
    M.set_current_theme(config.theme)
  end
  
  -- Setup highlights
  local highlights = safe_require("dashy.highlights")
  if highlights then
    highlights.setup(config)
  end
end

return M 