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
  rose = "#ea9a97",    -- Rose color for header
  gold = "#f6c177",    -- Gold color
  foam = "#9ccfd8",    -- Foam color
  pine = "#31748f",    -- Pine color
  iris = "#c4a7e7",    -- Iris color
}

-- Get theme colors (ensure we override any defaults)
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

  -- Add menu items
  local menu_items = M.get_menu_items()
  if menu_items and #menu_items > 0 then
    table.insert(content.center, "")
    for _, item in ipairs(menu_items) do
      local line = string.format("  [%s] %s", item.icon, item.desc)
      table.insert(content.center, line)
    end
  end

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
  
  -- Clear any existing highlights
  api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)
  
  -- Set up the DashboardHeader highlight group with the rose color
  vim.api.nvim_set_hl(0, "DashboardHeader", { fg = colors.rose, bg = colors.bg, bold = true })
  
  -- Apply header highlights (lines 2-7 contain the banner)
  for i = 2, 7 do
    local line = highlights[i - 1]
    if line then
      local start_col = line:find("[^ ]") or 1
      local end_col = line:len()
      api.nvim_buf_add_highlight(buf_id, ns_id, "DashboardHeader", i - 1, start_col - 1, end_col)
    end
  end

  -- Get menu items for highlighting
  local menu_items = M.get_menu_items()
  if menu_items and #menu_items > 0 then
    -- Find the start of menu items (after header and spacer)
    local menu_start = 9  -- After header (7 lines) and spacer (1 line)
    
    -- Apply highlights for each menu item
    for i, item in ipairs(menu_items) do
      local line_num = menu_start + i - 1
      local line = highlights[line_num]
      if line then
        -- Find icon position
        local icon_start = line:find("%[") + 1
        local icon_end = line:find("%]") - 1
        if icon_start and icon_end then
          -- Highlight icon
          api.nvim_buf_add_highlight(buf_id, ns_id, item.icon_hl, line_num - 1, icon_start - 1, icon_end)
        end
        
        -- Find description position
        local desc_start = line:find(item.desc)
        if desc_start then
          -- Highlight description
          api.nvim_buf_add_highlight(buf_id, ns_id, item.desc_hl, line_num - 1, desc_start - 1, desc_start + #item.desc - 1)
        end
      end
    end
  end
  
  -- Apply other highlights
  local highlight_groups = {
    -- Footer
    { group = "DashboardFooter", line = #highlights - 2, col_start = 2, col_end = 20 },
  }
  
  -- Apply remaining highlights
  for _, hl in ipairs(highlight_groups) do
    api.nvim_buf_add_highlight(buf_id, ns_id, hl.group, hl.line - 1, hl.col_start - 1, hl.col_end - 1)
  end
end

-- Get menu items
---@return table
function M.get_menu_items()
  -- Get configuration
  local config = require("dashy.config")
  if not config then
    return {}
  end

  -- Get full config
  local cfg = config.get()
  
  -- Return custom menu items if configured, otherwise return default items
  if cfg.sections and cfg.sections.center and cfg.sections.center.menu then
    return cfg.sections.center.menu
  end

  -- Default menu items
  return {
    {
      icon = "󰈞",
      icon_hl = "DashyIconFile",
      desc = "Find File",
      desc_hl = "DashyDesc",
      action = "Telescope find_files"
    },
    {
      icon = "󰈢",
      icon_hl = "DashyIconFile",
      desc = "New File",
      desc_hl = "DashyDesc",
      action = "enew"
    },
    {
      icon = "󰈆",
      icon_hl = "DashyIconQuit",
      desc = "Quit",
      desc_hl = "DashyDesc",
      action = "qa"
    }
  }
end

-- Return the module
return M 