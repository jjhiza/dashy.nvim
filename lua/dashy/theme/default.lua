---@mod dashy.theme.default Default theme for Dashy
---@brief [[
-- Provides the default theme for the Dashy dashboard.
-- Based on the Rose Pine Moon theme palette.
-- ]]

local M = {}

-- Default theme colors based on Rose Pine Moon
local colors = {
  -- Base colors
  bg = "#232136",      -- Base
  fg = "#e0def4",      -- Text
  accent = "#c4a7e7",  -- Iris
  border = "#393552",  -- Overlay
  
  -- Status colors
  success = "#9ccfd8", -- Foam
  warning = "#f6c177", -- Gold
  error = "#eb6f92",   -- Love
  info = "#31748f",    -- Pine
  
  -- Additional semantic colors
  title = "#c4a7e7",   -- Iris
  subtitle = "#9ccfd8", -- Foam
  muted = "#6e6a86",   -- Muted
  highlight = "#524f67", -- Highlight High
  
  -- UI element colors
  button_bg = "#2a273f",    -- Surface
  button_fg = "#e0def4",    -- Text
  button_border = "#393552", -- Overlay
  
  card_bg = "#2a273f",      -- Surface
  card_border = "#393552",  -- Overlay
  
  list_bg = "#2a273f",      -- Surface
  list_border = "#393552",  -- Overlay
  
  grid_bg = "#2a273f",      -- Surface
  grid_border = "#393552",  -- Overlay
  
  progress_bg = "#2a273f",  -- Surface
  progress_fg = "#c4a7e7",  -- Iris
  
  search_bg = "#2a273f",    -- Surface
  search_fg = "#e0def4",    -- Text
  search_border = "#393552", -- Overlay
  
  help_bg = "#2a273f",      -- Surface
  help_fg = "#e0def4",      -- Text
  help_border = "#393552",  -- Overlay
}

-- Get theme colors
---@return table
function M.get_colors()
  return colors
end

return M 