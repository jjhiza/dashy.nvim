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
  gold = "#f6c177",    -- Gold color
  foam = "#9ccfd8",    -- Foam color
  pine = "#31748f",    -- Pine color
  iris = "#c4a7e7",    -- Iris color
}

-- Banner gradient colors (from top to bottom)
local banner_colors = {
  colors.rose,    -- Line 1 (rose)
  colors.gold,    -- Line 2 (gold)
  colors.foam,    -- Line 3 (foam)
  colors.pine,    -- Line 4 (pine)
  colors.iris,    -- Line 5 (iris)
  colors.accent,  -- Line 6 (accent)
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
  -- Create namespace for highlights
  local ns_id = api.nvim_create_namespace("dashy_theme")
  
  -- Apply gradient colors to the banner using ExtMarks
  for i = 1, 6 do
    local color = banner_colors[i]
    -- Apply the highlight to the entire banner line using ExtMark
    vim.api.nvim_buf_set_extmark(buf_id, ns_id, i + 1, 0, {
      end_col = -1,  -- highlight to end of line
      hl_group = "DashboardHeader" .. i,
      priority = 100,  -- higher priority to override other highlights
    })
    -- Create the highlight group with the gradient color
    vim.api.nvim_set_hl(0, "DashboardHeader" .. i, { fg = color, bold = true })
  end
  
  -- Apply other highlights
  local highlight_groups = {
    -- Footer (keep footer highlight)
    { group = "DashboardFooter", line = #highlights - 2, col_start = 2, col_end = 20 },
  }
  
  -- Apply remaining highlights
  for _, hl in ipairs(highlight_groups) do
    api.nvim_buf_add_highlight(buf_id, ns_id, hl.group, hl.line - 1, hl.col_start - 1, hl.col_end - 1)
  end
end

-- Return the module
return M 