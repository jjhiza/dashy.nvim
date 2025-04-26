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
  local bg = theme.bg or "#232136" -- Rose Pine Moon Base
  local fg = theme.fg or "#e0def4" -- Rose Pine Moon Text
  local accent = theme.accent or "#eb6f92" -- Rose Pine Moon Love (Rose)
  local secondary = theme.secondary or "#31748f" -- Rose Pine Moon Pine
  local border = theme.border or "#393552" -- Rose Pine Moon Overlay
  local rose = "#ea9a97" -- Custom rose color for header
  
  -- Define highlight groups
  local highlights = {
    -- Dashboard base highlights
    DashboardNormal = { fg = fg, bg = bg },
    DashboardBorder = { fg = border, bg = bg },
    DashboardEndOfBuffer = { fg = bg, bg = bg },
    
    -- Dashboard header and footer
    DashboardHeader = { fg = rose, bg = bg, bold = true }, -- Custom rose color
    DashboardFooter = { fg = fg, bg = bg, italic = true },
    
    -- Dashboard title
    DashboardTitle = { fg = rose, bg = bg, bold = true }, -- Custom rose color
    
    -- Dashboard center menu
    DashboardCenter = { fg = fg, bg = bg },
    DashboardCenterCursor = { fg = "#31748f", bg = bg, bold = true }, -- Pine color for cursor line
    
    -- Dashboard sections
    DashboardSection = { fg = iris, bg = bg, bold = true }, -- Iris color for sections
    DashboardSubsection = { fg = fg, bg = bg, italic = true },
    
    -- Dashboard items
    DashboardItem = { fg = pine, bg = bg }, -- Pine color for normal items
    DashboardItemSelected = { fg = rose, bg = bg, bold = true }, -- Rose color for selected items
    DashboardItemHover = { fg = foam, bg = bg, italic = true }, -- Foam color for hover
    
    -- Dashboard buttons
    DashboardButton = { fg = fg, bg = bg },
    DashboardButtonSelected = { fg = "#31748f", bg = bg, bold = true }, -- Pine color for selection
    DashboardButtonHover = { fg = "#31748f", bg = bg, italic = true }, -- Pine color for hover
    DashboardKey = { fg = "#c4a7e7", bg = bg, bold = true }, -- Iris color for keys
    
    -- Dashboard cards
    DashboardCard = { fg = fg, bg = bg },
    DashboardCardTitle = { fg = "#eb6f92", bg = bg, bold = true }, -- Rose color
    DashboardCardContent = { fg = fg, bg = bg },
    
    -- Dashboard lists
    DashboardList = { fg = fg, bg = bg },
    DashboardListItem = { fg = fg, bg = bg },
    DashboardListItemSelected = { fg = "#31748f", bg = bg, bold = true }, -- Pine color for selection
    DashboardListItemHover = { fg = "#31748f", bg = bg, italic = true }, -- Pine color for hover
    DashboardBullet = { fg = "#c4a7e7", bg = bg }, -- Iris color for bullets
    
    -- Dashboard grids
    DashboardGrid = { fg = fg, bg = bg },
    DashboardGridItem = { fg = fg, bg = bg },
    DashboardGridItemSelected = { fg = "#31748f", bg = bg, bold = true }, -- Pine color for selection
    DashboardGridItemHover = { fg = "#31748f", bg = bg, italic = true }, -- Pine color for hover
    
    -- Dashboard progress bars
    DashboardProgress = { fg = fg, bg = bg },
    DashboardProgressFilled = { fg = "#eb6f92", bg = bg }, -- Rose color
    
    -- Dashboard search
    DashboardSearch = { fg = "#c4a7e7", bg = bg, bold = true }, -- Iris color for search
    DashboardSearchMatch = { fg = "#c4a7e7", bg = bg, bold = true, underline = true }, -- Iris color for search matches
    
    -- Dashboard help
    DashboardHelp = { fg = fg, bg = bg, italic = true },
    DashboardHelpKey = { fg = "#c4a7e7", bg = bg, bold = true }, -- Iris color for help keys
    
    -- Dashboard icons
    DashboardIcon = { fg = gold, bg = bg }, -- Gold color for icons
    DashboardIconSelected = { fg = rose, bg = bg, bold = true }, -- Rose color for selected icons
    
    -- Dashboard shortcuts
    DashboardShortcut = { fg = iris, bg = bg, bold = true }, -- Iris color for shortcuts
    DashboardShortcutSelected = { fg = rose, bg = bg, bold = true }, -- Rose color for selected shortcuts
    
    -- Dashboard status
    DashboardStatus = { fg = fg, bg = bg },
    DashboardStatusSuccess = { fg = "#9ccfd8", bg = bg }, -- Foam color
    DashboardStatusWarning = { fg = "#f6c177", bg = bg }, -- Gold color
    DashboardStatusError = { fg = "#eb6f92", bg = bg }, -- Love (Rose) color
    DashboardStatusInfo = { fg = "#31748f", bg = bg }, -- Pine color
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
  
  -- Use Rose Pink Moon colors specifically
  local rose = "#eb6f92"  -- Love/Rose color
  local pine = "#31748f"  -- Pine color
  local iris = "#c4a7e7"  -- Iris color
  local foam = "#9ccfd8"  -- Foam color
  local gold = "#f6c177"  -- Gold color
  
  local highlights = {
    DashboardNormal = { fg = colors.fg, bg = colors.bg },
    DashboardBorder = { fg = colors.border, bg = colors.bg },
    DashboardEndOfBuffer = { fg = colors.bg, bg = colors.bg },
    DashboardHeader = { fg = rose, bg = colors.bg, bold = true }, -- Rose color
    DashboardFooter = { fg = colors.fg, bg = colors.bg, italic = true },
    DashboardTitle = { fg = rose, bg = colors.bg, bold = true }, -- Rose color
    DashboardCenter = { fg = colors.fg, bg = colors.bg },
    DashboardCenterCursor = { fg = pine, bg = colors.bg, bold = true }, -- Pine color for cursor line
    DashboardSection = { fg = iris, bg = colors.bg, bold = true }, -- Iris color for sections
    DashboardSubsection = { fg = colors.fg, bg = colors.bg, italic = true },
    DashboardItem = { fg = pine, bg = colors.bg }, -- Pine color for normal items
    DashboardItemSelected = { fg = rose, bg = colors.bg, bold = true }, -- Rose color for selected items
    DashboardItemHover = { fg = foam, bg = colors.bg, italic = true }, -- Foam color for hover
    DashboardButton = { fg = colors.fg, bg = colors.bg },
    DashboardButtonSelected = { fg = pine, bg = colors.bg, bold = true }, -- Pine color for selection
    DashboardButtonHover = { fg = pine, bg = colors.bg, italic = true }, -- Pine color for hover
    DashboardKey = { fg = iris, bg = colors.bg, bold = true }, -- Iris color for keys
    DashboardCard = { fg = colors.fg, bg = colors.bg },
    DashboardCardTitle = { fg = rose, bg = colors.bg, bold = true }, -- Rose color
    DashboardCardContent = { fg = colors.fg, bg = colors.bg },
    DashboardList = { fg = colors.fg, bg = colors.bg },
    DashboardListItem = { fg = colors.fg, bg = colors.bg },
    DashboardListItemSelected = { fg = pine, bg = colors.bg, bold = true }, -- Pine color for selection
    DashboardListItemHover = { fg = pine, bg = colors.bg, italic = true }, -- Pine color for hover
    DashboardBullet = { fg = iris, bg = colors.bg }, -- Iris color for bullets
    DashboardGrid = { fg = colors.fg, bg = colors.bg },
    DashboardGridItem = { fg = colors.fg, bg = colors.bg },
    DashboardGridItemSelected = { fg = pine, bg = colors.bg, bold = true }, -- Pine color for selection
    DashboardGridItemHover = { fg = pine, bg = colors.bg, italic = true }, -- Pine color for hover
    DashboardProgress = { fg = colors.fg, bg = colors.bg },
    DashboardProgressFilled = { fg = rose, bg = colors.bg }, -- Rose color
    DashboardSearch = { fg = iris, bg = colors.bg, bold = true }, -- Iris color for search
    DashboardSearchMatch = { fg = iris, bg = colors.bg, bold = true, underline = true }, -- Iris color for search matches
    DashboardHelp = { fg = colors.fg, bg = colors.bg, italic = true },
    DashboardHelpKey = { fg = iris, bg = colors.bg, bold = true }, -- Iris color for help keys
    DashboardIcon = { fg = gold, bg = colors.bg }, -- Gold color for icons
    DashboardIconSelected = { fg = rose, bg = colors.bg, bold = true }, -- Rose color for selected icons
    DashboardShortcut = { fg = iris, bg = colors.bg, bold = true }, -- Iris color for shortcuts
    DashboardShortcutSelected = { fg = rose, bg = colors.bg, bold = true }, -- Rose color for selected shortcuts
    DashboardStatus = { fg = colors.fg, bg = colors.bg },
    DashboardStatusSuccess = { fg = foam, bg = colors.bg }, -- Foam color
    DashboardStatusWarning = { fg = gold, bg = colors.bg }, -- Gold color
    DashboardStatusError = { fg = rose, bg = colors.bg }, -- Love (Rose) color
    DashboardStatusInfo = { fg = pine, bg = colors.bg }, -- Pine color
  }
  
  -- Apply highlights
  for group, attrs in pairs(highlights) do
    api.nvim_set_hl(0, group, attrs)
  end
end

return M 