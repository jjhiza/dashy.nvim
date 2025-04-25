---@mod dashy.theme.rose-pine-moon Rose Pine Moon theme for Dashy
---@brief [[
-- A beautiful theme based on the Rose Pine Moon color palette.
-- Features soft, muted colors with a focus on readability and aesthetics.
-- ]]

local api = vim.api

-- Module definition
---@class DashyTheme
local M = {}

-- Theme colors based on Rose Pine Moon palette
local colors = {
  bg = "#232136",      -- Base background
  fg = "#e0def4",      -- Base foreground
  muted = "#908caa",   -- Muted text
  subtle = "#56526e",  -- Subtle borders
  accent = "#c4a7e7",  -- Accent color (purple)
  success = "#9ccfd8", -- Success color (cyan)
  warning = "#f6c177", -- Warning color (yellow)
  error = "#eb6f92",   -- Error color (red/rose)
  info = "#3e8fb0",    -- Info color (blue)
  rose = "#eb6f92",    -- Rose color for banner
}

-- Get theme colors
---@return table
function M.get_colors()
  return colors
end

-- Get theme content for the dashboard
---@param buf_id number Buffer ID
---@param win_id number Window ID
---@return table content The theme content
function M.get_content(buf_id, win_id)
  -- Get configuration
  local config = require("dashy.config")
  if not config then
    return nil
  end

  -- Get keymaps for shortcuts
  local keymaps = require("dashy.keymaps")
  if not keymaps then
    return nil
  end

  -- Generate content
  local content = {
    header = {
      "",
      "  ██████╗  █████╗ ███████╗██╗  ██╗██╗   ██╗",
      "  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝",
      "  ██║  ██║███████║███████╗███████║ ╚████╔╝ ",
      "  ██║  ██║██╔══██║╚════██║██╔══██║  ╚██╔╝  ",
      "  ██████╔╝██║  ██║███████║██║  ██║   ██║   ",
      "  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ",
      "",
    },
    center = {},
    footer = {
      "",
      "  Press ? for help",
      "",
    },
  }

  -- Add shortcuts section
  local shortcut_texts = keymaps.get_shortcut_display_texts()
  if shortcut_texts and #shortcut_texts > 0 then
    table.insert(content.center, "")
    table.insert(content.center, "  Shortcuts:")
    for _, text in ipairs(shortcut_texts) do
      table.insert(content.center, "  " .. text)
    end
  end

  return content
end

-- Apply highlights to the dashboard
---@param buf_id number Buffer ID
---@param highlights table The highlights to apply
function M.apply_highlights(buf_id, highlights)
  -- Define highlight groups
  local highlight_groups = {
    -- Header (using Rose color)
    { group = "DashboardHeader", line = 2, col_start = 2, col_end = 52, color = colors.rose },
    { group = "DashboardHeader", line = 3, col_start = 2, col_end = 52, color = colors.rose },
    { group = "DashboardHeader", line = 4, col_start = 2, col_end = 52, color = colors.rose },
    { group = "DashboardHeader", line = 5, col_start = 2, col_end = 52, color = colors.rose },
    { group = "DashboardHeader", line = 6, col_start = 2, col_end = 52, color = colors.rose },
    { group = "DashboardHeader", line = 7, col_start = 2, col_end = 52, color = colors.rose },
    { group = "DashboardHeader", line = 8, col_start = 2, col_end = 52, color = colors.rose },
    
    -- Footer
    { group = "DashboardFooter", line = #highlights - 2, col_start = 2, col_end = 20 },
  }

  -- Create namespace for highlights
  local ns_id = api.nvim_create_namespace("dashy_theme")
  
  -- Define the DashboardHeader highlight with the Rose color
  vim.api.nvim_set_hl(0, "DashboardHeader", { fg = colors.rose, bold = true })
  
  -- Apply highlights
  for _, hl in ipairs(highlight_groups) do
    api.nvim_buf_add_highlight(buf_id, ns_id, hl.group, hl.line - 1, hl.col_start - 1, hl.col_end - 1)
  end
end

-- Return the module
return M 