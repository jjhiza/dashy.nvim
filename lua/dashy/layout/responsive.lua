---@mod dashy.layout.responsive Responsive layout handling for Dashy
---@brief [[
-- Provides responsive layout handling for the Dashy dashboard.
-- Handles dynamic resizing, ultrawide monitors, and custom layout adjustments.
-- ]]

local api = vim.api

-- Module definition
---@class DashyResponsiveLayout
local M = {}

-- Get the safe require utility from the main module
local safe_require = require("dashy").safe_require

-- Calculate aspect ratio and layout type
---@param width number The editor width
---@param height number The editor height
---@return string layout_type The determined layout type
local function determine_layout_type(width, height)
  local aspect_ratio = width / height
  
  if width > 200 or aspect_ratio > 2.5 then
    return "ultrawide"
  elseif aspect_ratio > 1.8 then
    return "widescreen"
  elseif aspect_ratio < 1.2 then
    return "vertical"
  else
    return "standard"
  end
end

-- Adjust layout for ultrawide monitors
---@param buf_id number Buffer ID
---@param win_id number Window ID
---@param width number Editor width
---@param height number Editor height
---@return table dimensions The adjusted dimensions
local function adjust_ultrawide_layout(buf_id, win_id, width, height)
  -- Use 100% of available space
  local content_width = width
  local content_height = height
  
  -- Ensure minimum dimensions
  content_width = math.max(content_width, 80)
  content_height = math.max(content_height, 20)
  
  -- No need to center since we're using full space
  local row = 0
  local col = 0
  
  return {
    width = content_width,
    height = content_height,
    row = row,
    col = col,
  }
end

-- Adjust layout for widescreen monitors
---@param buf_id number Buffer ID
---@param win_id number Window ID
---@param width number Editor width
---@param height number Editor height
---@return table dimensions The adjusted dimensions
local function adjust_widescreen_layout(buf_id, win_id, width, height)
  -- Use 100% of available space
  local content_width = width
  local content_height = height
  
  -- Ensure minimum dimensions
  content_width = math.max(content_width, 80)
  content_height = math.max(content_height, 20)
  
  -- No need to center since we're using full space
  local row = 0
  local col = 0
  
  return {
    width = content_width,
    height = content_height,
    row = row,
    col = col,
  }
end

-- Adjust layout for vertical monitors
---@param buf_id number Buffer ID
---@param win_id number Window ID
---@param width number Editor width
---@param height number Editor height
---@return table dimensions The adjusted dimensions
local function adjust_vertical_layout(buf_id, win_id, width, height)
  -- Use 100% of available space
  local content_width = width
  local content_height = height
  
  -- Ensure minimum dimensions
  content_width = math.max(content_width, 50)
  content_height = math.max(content_height, 15)
  
  -- No need to center since we're using full space
  local row = 0
  local col = 0
  
  return {
    width = content_width,
    height = content_height,
    row = row,
    col = col,
  }
end

-- Adjust layout for standard monitors
---@param buf_id number Buffer ID
---@param win_id number Window ID
---@param width number Editor width
---@param height number Editor height
---@return table dimensions The adjusted dimensions
local function adjust_standard_layout(buf_id, win_id, width, height)
  -- Use 100% of available space
  local content_width = width
  local content_height = height
  
  -- Ensure minimum dimensions
  content_width = math.max(content_width, 60)
  content_height = math.max(content_height, 15)
  
  -- No need to center since we're using full space
  local row = 0
  local col = 0
  
  return {
    width = content_width,
    height = content_height,
    row = row,
    col = col,
  }
end

-- Calculate optimal dimensions based on screen size and content
---@param buf_id number Buffer ID
---@param win_id number Window ID
---@return table dimensions The calculated dimensions
function M.calculate_dimensions(buf_id, win_id)
  -- Get editor dimensions
  local width = api.nvim_win_get_width(0)
  local height = api.nvim_win_get_height(0)
  
  -- Determine layout type based on screen dimensions
  local layout_type = determine_layout_type(width, height)
  
  -- Adjust layout based on type
  local dimensions
  if layout_type == "ultrawide" then
    dimensions = adjust_ultrawide_layout(buf_id, win_id, width, height)
  elseif layout_type == "widescreen" then
    dimensions = adjust_widescreen_layout(buf_id, win_id, width, height)
  elseif layout_type == "vertical" then
    dimensions = adjust_vertical_layout(buf_id, win_id, width, height)
  else
    dimensions = adjust_standard_layout(buf_id, win_id, width, height)
  end
  
  return dimensions
end

-- Handle window resize
---@param buf_id number Buffer ID
---@param win_id number Window ID
function M.handle_resize(buf_id, win_id)
  if not api.nvim_win_is_valid(win_id) then
    return
  end
  
  -- Recalculate dimensions
  local dimensions = M.calculate_dimensions(buf_id, win_id)
  
  -- Apply new dimensions
  api.nvim_win_set_width(win_id, dimensions.width)
  api.nvim_win_set_height(win_id, dimensions.height)
  api.nvim_win_set_position(win_id, dimensions.row, dimensions.col)
end

-- Optimize layout for the current window
---@param buf_id number Buffer ID
---@param win_id number Window ID
function M.optimize_layout(buf_id, win_id)
  if not api.nvim_win_is_valid(win_id) then
    return
  end
  
  -- Set window options for optimal display
  api.nvim_win_set_option(win_id, "wrap", false)
  api.nvim_win_set_option(win_id, "linebreak", false)
  api.nvim_win_set_option(win_id, "breakindent", false)
  api.nvim_win_set_option(win_id, "breakat", "")
  api.nvim_win_set_option(win_id, "showbreak", "")
  api.nvim_win_set_option(win_id, "sidescroll", 0)
  api.nvim_win_set_option(win_id, "sidescrolloff", 0)
  api.nvim_win_set_option(win_id, "scrolloff", 0)
  api.nvim_win_set_option(win_id, "scrollbind", false)
  api.nvim_win_set_option(win_id, "cursorbind", false)
  api.nvim_win_set_option(win_id, "diff", false)
  api.nvim_win_set_option(win_id, "spell", false)
  api.nvim_win_set_option(win_id, "spelllang", "")
  api.nvim_win_set_option(win_id, "spellcapcheck", "")
  api.nvim_win_set_option(win_id, "spellfile", "")
  api.nvim_win_set_option(win_id, "spelloptions", "")
  api.nvim_win_set_option(win_id, "conceallevel", 0)
  api.nvim_win_set_option(win_id, "concealcursor", "")
  api.nvim_win_set_option(win_id, "colorcolumn", "")
  api.nvim_win_set_option(win_id, "winhl", "Normal:DashboardNormal,FloatBorder:DashboardBorder")
  api.nvim_win_set_option(win_id, "winblend", 0)
end

-- Return the module
return M

