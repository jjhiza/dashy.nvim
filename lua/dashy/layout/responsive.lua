---@mod dashy.layout.responsive Responsive layout handling for Dashy
---@brief [[
Provides responsive layout handling for the Dashy dashboard.
Handles dynamic resizing, ultrawide monitors, and custom layout adjustments.
]]

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
  -- For ultrawide, we want to limit the width to prevent extreme stretching
  local content_width = math.floor(width * 0.4) -- 40% of screen width
  local content_height = math.floor(height * 0.8) -- 80% of screen height
  
  -- Ensure minimum dimensions
  content_width = math.max(content_width, 80)
  content_height = math.max(content_height, 20)
  
  -- Center the window
  local row = math.floor((height - content_height) / 2)
  local col = math.floor((width - content_width) / 2)
  
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
  -- For widescreen, we want to use a bit more width
  local content_width = math.floor(width * 0.6) -- 60% of screen width
  local content_height = math.floor(height * 0.8) -- 80% of screen height
  
  -- Ensure minimum dimensions
  content_width = math.max(content_width, 80)
  content_height = math.max(content_height, 20)
  
  -- Center the window
  local row = math.floor((height - content_height) / 2)
  local col = math.floor((width - content_width) / 2)
  
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
  -- For vertical layouts, we want to use most of the width
  local content_width = math.floor(width * 0.9) -- 90% of screen width
  local content_height = math.floor(height * 0.7) -- 70% of screen height
  
  -- Ensure minimum dimensions
  content_width = math.max(content_width, 50)
  content_height = math.max(content_height, 15)
  
  -- Center the window
  local row = math.floor((height - content_height) / 2)
  local col = math.floor((width - content_width) / 2)
  
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
  -- For standard layouts, we want a balanced approach
  local content_width = math.floor(width * 0.7) -- 70% of screen width
  local content_height = math.floor(height * 0.75) -- 75% of screen height
  
  -- Ensure minimum dimensions
  content_width = math.max(content_width, 60)
  content_height = math.max(content_height, 15)
  
  -- Center the window
  local row = math.floor((height - content_height) / 2)
  local col = math.floor((width - content_width) / 2)
  
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
  
  -- Apply smooth transitions for resizing
  M.apply_smooth_transition(win_id, dimensions)
  
  return dimensions
end

-- Apply smooth transition when resizing
---@param win_id number Window ID
---@param dimensions table The target dimensions
local function apply_smooth_transition(win_id, dimensions)
  if not api.nvim_win_is_valid(win_id) then
    return
  end
  
  -- Get current dimensions
  local current_width = api.nvim_win_get_width(win_id)
  local current_height = api.nvim_win_get_height(win_id)
  local current_row = api.nvim_win_get_position(win_id)[1]
  local current_col = api.nvim_win_get_position(win_id)[2]
  
  -- Calculate step size for smooth transition
  local width_step = math.ceil(math.abs(dimensions.width - current_width) / 5)
  local height_step = math.ceil(math.abs(dimensions.height - current_height) / 5)
  local row_step = math.ceil(math.abs(dimensions.row - current_row) / 5)
  local col_step = math.ceil(math.abs(dimensions.col - current_col) / 5)
  
  -- Apply transition in steps
  local steps = 5
  local step = 0
  
  local timer = vim.loop.new_timer()
  timer:start(0, 20, vim.schedule_wrap(function()
    step = step + 1
    
    -- Calculate intermediate dimensions
    local intermediate_width = current_width + (dimensions.width - current_width) * step / steps
    local intermediate_height = current_height + (dimensions.height - current_height) * step / steps
    local intermediate_row = current_row + (dimensions.row - current_row) * step / steps
    local intermediate_col = current_col + (dimensions.col - current_col) * step / steps
    
    -- Apply intermediate dimensions
    api.nvim_win_set_width(win_id, math.floor(intermediate_width))
    api.nvim_win_set_height(win_id, math.floor(intermediate_height))
    api.nvim_win_set_position(win_id, math.floor(intermediate_row), math.floor(intermediate_col))
    
    -- Stop timer when transition is complete
    if step >= steps then
      timer:stop()
      timer:close()
    end
  end))
end

-- Apply smooth transition when resizing
---@param win_id number Window ID
---@param dimensions table The target dimensions
function M.apply_smooth_transition(win_id, dimensions)
  apply_smooth_transition(win_id, dimensions)
end

-- Handle window resize events
---@param buf_id number Buffer ID
---@param win_id number Window ID
function M.handle_resize(buf_id, win_id)
  -- Recalculate dimensions
  local dimensions = M.calculate_dimensions(buf_id, win_id)
  
  -- Apply new dimensions with smooth transition
  M.apply_smooth_transition(win_id, dimensions)
  
  -- Redraw content
  local layout = safe_require("dashy.layout")
  if layout then
    layout.redraw()
  end
end

-- Optimize layout for different screen sizes
---@param buf_id number Buffer ID
---@param win_id number Window ID
function M.optimize_layout(buf_id, win_id)
  -- Get screen dimensions
  local width = api.nvim_win_get_width(0)
  local height = api.nvim_win_get_height(0)
  
  -- Determine layout type
  local layout_type = determine_layout_type(width, height)
  
  -- Apply layout-specific optimizations
  if layout_type == "ultrawide" then
    -- For ultrawide, use a grid layout for shortcuts
    api.nvim_win_set_option(win_id, "winblend", 5) -- Slight transparency
  elseif layout_type == "widescreen" then
    -- For widescreen, use a balanced layout
    api.nvim_win_set_option(win_id, "winblend", 0) -- No transparency
  elseif layout_type == "vertical" then
    -- For vertical, use a compact layout
    api.nvim_win_set_option(win_id, "winblend", 0) -- No transparency
  else
    -- For standard, use default layout
    api.nvim_win_set_option(win_id, "winblend", 0) -- No transparency
  end
  
  -- Apply common optimizations
  api.nvim_win_set_option(win_id, "cursorline", false)
  api.nvim_win_set_option(win_id, "number", false)
  api.nvim_win_set_option(win_id, "relativenumber", false)
  api.nvim_win_set_option(win_id, "signcolumn", "no")
  api.nvim_win_set_option(win_id, "foldcolumn", "0")
  api.nvim_win_set_option(win_id, "list", false)
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
end

return M

