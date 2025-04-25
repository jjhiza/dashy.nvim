---@mod dashy.highlights Highlight groups for Dashy
---@brief [[
-- Defines highlight groups for the Dashy dashboard.
-- Provides consistent styling across different themes.
-- ]]

local api = vim.api

-- Module definition
---@class DashyHighlights
local M = {}

-- Get the safe require utility from the main module
local safe_require = require("dashy").safe_require

-- Define highlight groups
---@param config table Configuration options
function M.setup(config)
  -- Get theme colors
  local theme = config.theme or {}
  local bg = theme.bg or "#1a1b26"
  local fg = theme.fg or "#a9b1d6"
  local accent = theme.accent or "#7aa2f7"
  local border = theme.border or "#24283b"
  
  -- Define highlight groups
  local highlights = {
    -- Dashboard base highlights
    DashboardNormal = { fg = fg, bg = bg },
    DashboardBorder = { fg = border, bg = bg },
    DashboardEndOfBuffer = { fg = bg, bg = bg },
    
    -- Dashboard header and footer
    DashboardHeader = { fg = accent, bg = bg, bold = true },
    DashboardFooter = { fg = fg, bg = bg, italic = true },
    
    -- Dashboard title
    DashboardTitle = { fg = accent, bg = bg, bold = true },
    
    -- Dashboard center menu
    DashboardCenter = { fg = fg, bg = bg },
    
    -- Dashboard sections
    DashboardSection = { fg = accent, bg = bg, bold = true },
    DashboardSubsection = { fg = fg, bg = bg, italic = true },
    
    -- Dashboard items
    DashboardItem = { fg = fg, bg = bg },
    DashboardItemSelected = { fg = accent, bg = bg, bold = true },
    DashboardItemHover = { fg = accent, bg = bg, italic = true },
    
    -- Dashboard buttons
    DashboardButton = { fg = fg, bg = bg },
    DashboardButtonSelected = { fg = accent, bg = bg, bold = true },
    DashboardButtonHover = { fg = accent, bg = bg, italic = true },
    DashboardKey = { fg = accent, bg = bg, bold = true },
    
    -- Dashboard cards
    DashboardCard = { fg = fg, bg = bg },
    DashboardCardTitle = { fg = accent, bg = bg, bold = true },
    DashboardCardContent = { fg = fg, bg = bg },
    
    -- Dashboard lists
    DashboardList = { fg = fg, bg = bg },
    DashboardListItem = { fg = fg, bg = bg },
    DashboardListItemSelected = { fg = accent, bg = bg, bold = true },
    DashboardListItemHover = { fg = accent, bg = bg, italic = true },
    DashboardBullet = { fg = accent, bg = bg },
    
    -- Dashboard grids
    DashboardGrid = { fg = fg, bg = bg },
    DashboardGridItem = { fg = fg, bg = bg },
    DashboardGridItemSelected = { fg = accent, bg = bg, bold = true },
    DashboardGridItemHover = { fg = accent, bg = bg, italic = true },
    
    -- Dashboard progress bars
    DashboardProgress = { fg = fg, bg = bg },
    DashboardProgressFilled = { fg = accent, bg = bg },
    
    -- Dashboard search
    DashboardSearch = { fg = accent, bg = bg, bold = true },
    DashboardSearchMatch = { fg = accent, bg = bg, bold = true, underline = true },
    
    -- Dashboard help
    DashboardHelp = { fg = fg, bg = bg, italic = true },
    DashboardHelpKey = { fg = accent, bg = bg, bold = true },
    
    -- Dashboard icons
    DashboardIcon = { fg = accent, bg = bg },
    
    -- Dashboard status
    DashboardStatus = { fg = fg, bg = bg },
    DashboardStatusSuccess = { fg = "#9ece6a", bg = bg },
    DashboardStatusWarning = { fg = "#e0af68", bg = bg },
    DashboardStatusError = { fg = "#f7768e", bg = bg },
    DashboardStatusInfo = { fg = "#7aa2f7", bg = bg },
  }
  
  -- Apply highlights
  for group, attrs in pairs(highlights) do
    api.nvim_set_hl(0, group, attrs)
  end
end

-- Update highlight groups based on theme
---@param theme_name string Theme name
function M.update_theme(theme_name)
  local config = safe_require("dashy.config")
  if not config then
    return
  end
  
  local theme = safe_require("dashy.theme." .. theme_name)
  if not theme or not theme.get_colors then
    return
  end
  
  local colors = theme.get_colors()
  local highlights = {
    DashboardNormal = { fg = colors.fg, bg = colors.bg },
    DashboardBorder = { fg = colors.border, bg = colors.bg },
    DashboardEndOfBuffer = { fg = colors.bg, bg = colors.bg },
    DashboardHeader = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardFooter = { fg = colors.fg, bg = colors.bg, italic = true },
    DashboardTitle = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardCenter = { fg = colors.fg, bg = colors.bg },
    DashboardSection = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardSubsection = { fg = colors.fg, bg = colors.bg, italic = true },
    DashboardItem = { fg = colors.fg, bg = colors.bg },
    DashboardItemSelected = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardItemHover = { fg = colors.accent, bg = colors.bg, italic = true },
    DashboardButton = { fg = colors.fg, bg = colors.bg },
    DashboardButtonSelected = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardButtonHover = { fg = colors.accent, bg = colors.bg, italic = true },
    DashboardKey = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardCard = { fg = colors.fg, bg = colors.bg },
    DashboardCardTitle = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardCardContent = { fg = colors.fg, bg = colors.bg },
    DashboardList = { fg = colors.fg, bg = colors.bg },
    DashboardListItem = { fg = colors.fg, bg = colors.bg },
    DashboardListItemSelected = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardListItemHover = { fg = colors.accent, bg = colors.bg, italic = true },
    DashboardBullet = { fg = colors.accent, bg = colors.bg },
    DashboardGrid = { fg = colors.fg, bg = colors.bg },
    DashboardGridItem = { fg = colors.fg, bg = colors.bg },
    DashboardGridItemSelected = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardGridItemHover = { fg = colors.accent, bg = colors.bg, italic = true },
    DashboardProgress = { fg = colors.fg, bg = colors.bg },
    DashboardProgressFilled = { fg = colors.accent, bg = colors.bg },
    DashboardSearch = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardSearchMatch = { fg = colors.accent, bg = colors.bg, bold = true, underline = true },
    DashboardHelp = { fg = colors.fg, bg = colors.bg, italic = true },
    DashboardHelpKey = { fg = colors.accent, bg = colors.bg, bold = true },
    DashboardIcon = { fg = colors.accent, bg = colors.bg },
    DashboardStatus = { fg = colors.fg, bg = colors.bg },
    DashboardStatusSuccess = { fg = colors.success or "#9ece6a", bg = colors.bg },
    DashboardStatusWarning = { fg = colors.warning or "#e0af68", bg = colors.bg },
    DashboardStatusError = { fg = colors.error or "#f7768e", bg = colors.bg },
    DashboardStatusInfo = { fg = colors.info or "#7aa2f7", bg = colors.bg },
  }
  
  -- Apply highlights
  for group, attrs in pairs(highlights) do
    api.nvim_set_hl(0, group, attrs)
  end
end

return M 