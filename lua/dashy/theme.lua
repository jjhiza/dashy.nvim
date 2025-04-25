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
  vim.notify("Applying theme: " .. theme_name, vim.log.levels.INFO)
  
  -- Try to load theme module
  local theme_module = safe_require("dashy.theme." .. theme_name)
  if not theme_module then
    vim.notify("Failed to load theme module: " .. theme_name, vim.log.levels.ERROR)
    return
  end
  
  -- Get theme content and apply it
  if theme_module.get_content then
    vim.notify("Getting content from theme module", vim.log.levels.INFO)
    local win_id = api.nvim_get_current_win()
    local content = theme_module.get_content(buf_id, win_id)
    if content then
      vim.notify("Content received from theme module", vim.log.levels.INFO)
      -- Combine all content
      local lines = {}
      
      -- Get window width for centering
      local win_width = api.nvim_win_get_width(win_id)
      
      -- Center header content
      for _, line in ipairs(content.header) do
        local centered_line = M.center_line(line, win_width)
        table.insert(lines, centered_line)
      end
      
      -- Add a spacer
      table.insert(lines, "")
      
      -- Calculate the maximum length of menu items for alignment
      local menu_items = content.center
      local menu_item_width = 0
      for _, line in ipairs(menu_items) do
        menu_item_width = math.max(menu_item_width, vim.fn.strdisplaywidth(line))
      end
      
      -- Calculate the common starting position for all menu items
      local center_position = math.floor((win_width - menu_item_width) / 2)
      
      -- Center menu items with consistent left alignment
      for _, line in ipairs(menu_items) do
        local padded_line = string.rep(" ", center_position) .. line
        table.insert(lines, padded_line)
      end
      
      -- Add a spacer
      table.insert(lines, "")
      
      -- Center footer content
      for _, line in ipairs(content.footer) do
        local centered_line = M.center_line(line, win_width)
        table.insert(lines, centered_line)
      end
      
      vim.notify("Setting buffer content with " .. #lines .. " lines", vim.log.levels.INFO)
      
      -- Set buffer content
      api.nvim_buf_set_option(buf_id, "modifiable", true)
      api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      api.nvim_buf_set_option(buf_id, "modifiable", false)
      
      -- Apply theme highlights
      if theme_module.apply_highlights then
        vim.notify("Applying highlights", vim.log.levels.INFO)
        theme_module.apply_highlights(buf_id, lines)
      end
    else
      vim.notify("No content received from theme module", vim.log.levels.ERROR)
    end
  else
    vim.notify("Theme module does not have get_content function", vim.log.levels.ERROR)
  end
  
  -- Set buffer-specific highlights
  local ns_id = vim.api.nvim_create_namespace("dashy_theme")
  api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)
  
  -- Apply background color
  api.nvim_buf_set_option(buf_id, "winhl", string.format("Normal:DashboardNormal,EndOfBuffer:DashboardEndOfBuffer"))
  
  -- Apply border highlights if window exists
  local win_id = api.nvim_get_current_win()
  if win_id then
    api.nvim_win_set_option(win_id, "winhl", string.format("Normal:DashboardNormal,EndOfBuffer:DashboardEndOfBuffer"))
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