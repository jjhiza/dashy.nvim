---@mod dashy.theme.modern Modern theme for Dashy
---@brief [[
-- Implements a modern, responsive theme for the Dashy dashboard.
-- Features advanced ExtMark usage, responsive design, and dynamic content.
-- ]]

local api = vim.api
local uv = vim.uv

-- Module definition
---@class DashyThemeModern
local M = {}

-- Get the safe require utility from the main module
local safe_require = require("dashy").safe_require

-- Define namespace for ExtMarks
local ns = api.nvim_create_namespace("dashy.theme.modern")

-- ASCII art header (small version for smaller screens)
local header_small = {
  "  ██████╗   █████╗  ███████╗ ██╗  ██╗ ██╗   ██╗ ",
  "  ██╔══██╗ ██╔══██╗ ██╔════╝ ██║  ██║ ╚██╗ ██╔╝ ",
  "  ██║  ██║ ███████║ ███████╗ ███████║  ╚████╔╝  ",
  "  ██║  ██║ ██╔══██║ ╚════██║ ██╔══██║   ╚██╔╝   ",
  "  ██████╔╝ ██║  ██║ ███████║ ██║  ██║    ██║    ",
  "  ╚═════╝  ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝    ╚═╝    ",
}

-- ASCII art header (large version)
local header_large = {
  " ██████╗   █████╗  ███████╗ ██╗  ██╗ ██╗   ██╗    ███╗   ██╗ ██╗   ██╗ ██╗ ███╗   ███╗ ",
  " ██╔══██╗ ██╔══██╗ ██╔════╝ ██║  ██║ ╚██╗ ██╔╝    ████╗  ██║ ██║   ██║ ██║ ████╗ ████║ ",
  " ██║  ██║ ███████║ ███████╗ ███████║  ╚████╔╝     ██╔██╗ ██║ ██║   ██║ ██║ ██╔████╔██║ ",
  " ██║  ██║ ██╔══██║ ╚════██║ ██╔══██║   ╚██╔╝      ██║╚██╗██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ",
  " ██████╔╝ ██║  ██║ ███████║ ██║  ██║    ██║       ██║ ╚████║  ╚████╔╝  ██║ ██║ ╚═╝ ██║ ",
  " ╚═════╝  ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝    ╚═╝       ╚═╝  ╚═══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ",
}

-- Default menu items
local default_menu_items = {
  {
    icon = "󰮗",
    icon_hl = "DashyIconFile",
    desc = "Find File",
    desc_hl = "DashyDesc",
    action = "Telescope find_files",
  },
  {
    icon = "󰬵",
    icon_hl = "DashyIconSearch",
    desc = "Live Grep",
    desc_hl = "DashyDesc",
    action = "Telescope live_grep",
  },
  {
    icon = "",
    icon_hl = "DashyIconRecent",
    desc = "Recent Files",
    desc_hl = "DashyDesc",
    action = "Telescope oldfiles",
  },
  -- Uncomment if you have project.nvim installed, and would like access to this functionality
  -- {
  --   icon = "",
  --   icon_hl = "DashyIconProject",
  --   desc = "Projects",
  --   desc_hl = "DashyDesc",
  --   action = "Telescope projects",
  -- },
  {
    icon = "",
    icon_hl = "DashyIconConfig",
    desc = "Config",
    desc_hl = "DashyDesc",
    action = "edit ~/.config/nvim/init.lua",
  },
  {
    icon = "󰒲",
    icon_hl = "DashyIconLazy",
    desc = "Lazy",
    desc_hl = "DashyDesc",
    action = "Lazy",
  },
  {
    icon = "󰈆",
    icon_hl = "DashyIconQuit",
    desc = "Quit",
    desc_hl = "DashyDesc",
    action = "qa",
  },
}

-- Theme colors based on modern palette
local colors = {
  bg = "#1a1b26",      -- Base background
  fg = "#a9b1d6",      -- Base foreground
  muted = "#565f89",   -- Muted text
  subtle = "#24283b",  -- Subtle borders
  accent = "#7aa2f7",  -- Accent color (blue)
  success = "#9ece6a", -- Success color (green)
  warning = "#e0af68", -- Warning color (yellow)
  error = "#f7768e",   -- Error color (red)
  info = "#7dcfff",    -- Info color (cyan)
}

-- Get menu items
---@return table
function M.get_menu_items()
  return default_menu_items
end

-- Get theme colors
---@return table
function M.get_colors()
  return colors
end

-- Helper function to detect icon support
---@return boolean has_icons Whether the devicons plugin is available
local function has_icon_support()
  return pcall(require, "nvim-web-devicons")
end

-- Create a menu item with proper formatting and icons
---@param item table The menu item configuration
---@param width number The available width
---@return string formatted_item The formatted menu item
local function format_menu_item(item, width)
  local icon = item.icon or ""
  local desc = item.desc or ""
  
  -- Calculate spacing for centering
  local total_width = vim.fn.strdisplaywidth(icon) + vim.fn.strdisplaywidth(desc) + 10
  local padding = math.floor((width - total_width) / 2)
  if padding < 0 then padding = 2 end
  
  -- Create the item with proper spacing
  return string.rep(" ", padding) .. icon .. "  " .. desc
end

-- Apply ExtMarks for menu items to add highlights
---@param bufnr number Buffer ID
---@param items table The menu items
---@param start_line number Starting line number
local function apply_menu_extmarks(bufnr, items, start_line)
  -- Clear existing extmarks in the namespace
  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  
  -- Apply new extmarks for each item
  for i, item in ipairs(items) do
    local line_num = start_line + i - 1
    local line_content = api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)[1]
    
    -- Find positions of each component
    local icon_pos = line_content:find(item.icon) or 0
    local desc_pos = line_content:find(item.desc) or 0
    
    -- Apply highlights if positions are found
    if icon_pos > 0 and item.icon_hl then
      api.nvim_buf_set_extmark(bufnr, ns, line_num, icon_pos - 1, {
        end_col = icon_pos - 1 + vim.fn.strdisplaywidth(item.icon),
        hl_group = item.icon_hl,
      })
    end
    
    if desc_pos > 0 and item.desc_hl then
      api.nvim_buf_set_extmark(bufnr, ns, line_num, desc_pos - 1, {
        end_col = desc_pos - 1 + vim.fn.strdisplaywidth(item.desc),
        hl_group = item.desc_hl,
      })
    end
  end
end

-- Get a formatted header based on available width
---@param width number Available width
---@return table header The header lines
local function get_header(width)
  -- Use smaller header for narrow windows
  if width < 80 then
    return header_small
  else
    return header_large
  end
end

-- Apply gradient color to header using ExtMarks
---@param bufnr number Buffer ID
---@param header_lines table Header lines
---@param start_line number Starting line number
local function apply_header_gradient(bufnr, header_lines, start_line)
  -- Define gradient colors
  local colors = {
    "#7aa2f7",
    "#7dcfff",
    "#9ece6a",
    "#e0af68",
    "#bb9af7",
    "#ff9e64",
  }
  
  -- Create highlight groups for gradient
  for i, color in ipairs(colors) do
    local hl_group = "DashyHeaderGradient" .. i
    vim.cmd(string.format("highlight %s guifg=%s", hl_group, color))
  end
  
  -- Apply gradient to header lines
  for i, _ in ipairs(header_lines) do
    local line_num = start_line + i - 1
    local hl_group = "DashyHeaderGradient" .. ((i - 1) % #colors + 1)
    
    api.nvim_buf_set_extmark(bufnr, ns, line_num, 0, {
      line_hl_group = hl_group,
    })
  end
end

-- Generate dynamic footer with system information
---@return table footer_lines The footer lines
local function generate_footer()
  local footer = {}
  
  -- Get Neovim version
  local version = vim.version()
  local nvim_version_info = string.format("Neovim v%d.%d.%d", version.major, version.minor, version.patch)
  
  -- Get system info
  local sysname = uv.os_uname().sysname
  local hostname = uv.os_uname().machine
  local system_info = string.format("%s %s", sysname, hostname)
  
  -- Get plugin stats
  local plugin_count = "0"
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    plugin_count = tostring(lazy.stats().count)
  end
  local plugins_info = string.format("Plugins: %s", plugin_count)
  
  -- Get current time
  local datetime = os.date("%Y-%m-%d %H:%M:%S")
  
  -- Format footer
  table.insert(footer, "")
  table.insert(footer, system_info)
  table.insert(footer, nvim_version_info .. " | " .. plugins_info)
  table.insert(footer, datetime)
  
  return footer
end

-- Get theme content based on window dimensions
---@param bufnr number Buffer ID
---@param winid number Window ID
---@return table? content The theme content, or nil if error
function M.get_content(bufnr, winid)
  -- Get window dimensions
  local width = api.nvim_win_get_width(winid)
  local height = api.nvim_win_get_height(winid)
  
  -- Get config
  local config = safe_require("dashy.config")
  if not config then
    return nil
  end
  
  -- Get full config
  local cfg = config.get()
  
  -- Generate content
  local content = {
    header = get_header(width),
    center = {},
    footer = generate_footer(),
  }
  
  -- Add spacing between sections
  table.insert(content.center, "")
  table.insert(content.center, "")
  
  -- Format menu items with better spacing for full-screen
  local menu_items = cfg.sections.center and cfg.sections.center.menu or default_menu_items
  
  -- Calculate optimal spacing for full-screen layout
  local menu_width = 0
  for _, item in ipairs(menu_items) do
    local item_width = vim.fn.strdisplaywidth(format_menu_item(item, width))
    if item_width > menu_width then
      menu_width = item_width
    end
  end
  
  -- Add menu items with proper spacing
  for _, item in ipairs(menu_items) do
    table.insert(content.center, format_menu_item(item, menu_width))
  end
  
  -- Add more spacing at the bottom
  table.insert(content.center, "")
  table.insert(content.center, "")
  
  -- Schedule ExtMarks application for after buffer rendering
  vim.schedule(function()
    if api.nvim_buf_is_valid(bufnr) then
      -- Calculate header start line (should be 1 in most cases)
      local header_start = 1
      
      -- Apply header gradient
      apply_header_gradient(bufnr, content.header, header_start)
      
      -- Apply menu item highlights
      local center_start = header_start + #content.header + 1
      apply_menu_extmarks(bufnr, menu_items, center_start)
    end
  end)
  
  return content
end

-- Apply highlights to the dashboard
---@param buf_id number Buffer ID
---@param highlights table The highlights to apply
function M.apply_highlights(buf_id, highlights)
  -- Define highlight groups
  local highlight_groups = {
    -- Header
    { group = "DashboardHeader", line = 1, col_start = 1, col_end = 80 },
    { group = "DashboardHeader", line = 2, col_start = 1, col_end = 80 },
    { group = "DashboardHeader", line = 3, col_start = 1, col_end = 80 },
    { group = "DashboardHeader", line = 4, col_start = 1, col_end = 80 },
    { group = "DashboardHeader", line = 5, col_start = 1, col_end = 80 },
    { group = "DashboardHeader", line = 6, col_start = 1, col_end = 80 },
    
    -- Footer
    { group = "DashboardFooter", line = #highlights - 3, col_start = 1, col_end = 20 },
    { group = "DashboardFooter", line = #highlights - 2, col_start = 1, col_end = 20 },
    { group = "DashboardFooter", line = #highlights - 1, col_start = 1, col_end = 20 },
  }

  -- Apply highlights
  local ns_id = api.nvim_get_namespace("dashy_theme")
  for _, hl in ipairs(highlight_groups) do
    api.nvim_buf_add_highlight(buf_id, ns_id, hl.group, hl.line - 1, hl.col_start - 1, hl.col_end - 1)
  end
end

-- Adjust the theme for different layout types
---@param bufnr number Buffer ID
---@param winid number Window ID
---@param layout_type string The layout type
---@param dimensions table The window dimensions
function M.adjust_for_layout(bufnr, winid, layout_type, dimensions)
  if layout_type == "ultrawide" then
    -- For ultrawide, we want to ensure content is well-centered
    -- This is handled by layout adjustment, but we can refresh ExtMarks
    vim.schedule(function()
      if api.nvim_buf_is_valid(bufnr) then
        -- Determine which header to use
        local header = get_header(dimensions.width)
        
        -- Calculate header start line
        local header_start = 1
        
        -- Reapply header gradient
        apply_header_gradient(bufnr, header, header_start)
        
        -- Refresh menu extmarks
        local config = safe_require("dashy.config")
        if config then
          local cfg = config.get()
          local menu_items = cfg.sections.center and cfg.sections.center.menu or default_menu_items
          local center_start = header_start + #header + 1
          apply_menu_extmarks(bufnr, menu_items, center_start)
        end
      end
    end)
  end
end

return M

