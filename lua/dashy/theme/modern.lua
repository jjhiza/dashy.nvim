---@mod dashy.theme.modern Modern theme for Dashy
---@brief [[
Implements a modern, responsive theme for the Dashy dashboard.
Features advanced ExtMark usage, responsive design, and dynamic content.
]]

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
    icon = "󰈞",
    icon_hl = "DashyIconFile",
    desc = "Find File",
    desc_hl = "DashyDesc",
    key = "f",
    key_hl = "DashyShortcut",
    action = "Telescope find_files",
  },
  {
    icon = "󰊄",
    icon_hl = "DashyIconSearch",
    desc = "Live Grep",
    desc_hl = "DashyDesc",
    key = "g",
    key_hl = "DashyShortcut",
    action = "Telescope live_grep",
  },
  {
    icon = "󰷏",
    icon_hl = "DashyIconRecent",
    desc = "Recent Files",
    desc_hl = "DashyDesc",
    key = "r",
    key_hl = "DashyShortcut",
    action = "Telescope oldfiles",
  },
  {
    icon = "󰚰",
    icon_hl = "DashyIconProject",
    desc = "Projects",
    desc_hl = "DashyDesc",
    key = "p",
    key_hl = "DashyShortcut",
    action = "Telescope projects",
  },
  {
    icon = "󰖟",
    icon_hl = "DashyIconConfig",
    desc = "Config",
    desc_hl = "DashyDesc",
    key = "c",
    key_hl = "DashyShortcut",
    action = "edit ~/.config/nvim/init.lua",
  },
  {
    icon = "󰩂",
    icon_hl = "DashyIconLazy",
    desc = "Lazy",
    desc_hl = "DashyDesc",
    key = "l",
    key_hl = "DashyShortcut",
    action = "Lazy",
  },
  {
    icon = "󰿅",
    icon_hl = "DashyIconQuit",
    desc = "Quit",
    desc_hl = "DashyDesc",
    key = "q",
    key_hl = "DashyShortcut",
    action = "qa",
  },
}

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
  local key = item.key or ""
  
  -- Format with icon if available, otherwise just text
  if has_icon_support() then
    -- Calculate spacing for centering
    local total_width = vim.fn.strdisplaywidth(icon) + vim.fn.strdisplaywidth(desc) + vim.fn.strdisplaywidth(key) + 10
    local padding = math.floor((width - total_width) / 2)
    if padding < 0 then padding = 2 end
    
    -- Create the item with proper spacing
    return string.rep(" ", padding) .. icon .. "  " .. desc .. string.rep(" ", 4) .. "[" .. key .. "]"
  else
    -- No icon support, use text-only format
    local total_width = vim.fn.strdisplaywidth(desc) + vim.fn.strdisplaywidth(key) + 6
    local padding = math.floor((width - total_width) / 2)
    if padding < 0 then padding = 2 end
    
    -- Create the item with proper spacing
    return string.rep(" ", padding) .. desc .. string.rep(" ", 4) .. "[" .. key .. "]"
  end
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
    local key_pos = line_content:find("%[" .. item.key .. "%]") or 0
    
    -- Apply highlights if positions are found
    if has_icon_support() and icon_pos > 0 and item.icon_hl then
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
    
    if key_pos > 0 and item.key_hl then
      -- Highlight just the key, not the brackets
      api.nvim_buf_set_extmark(bufnr, ns, line_num, key_pos, {
        end_col = key_pos + #item.key,
        hl_group = item.key_hl,
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
  
  -- Format menu items
  local menu_items = cfg.sections.center and cfg.sections.center.menu or default_menu_items
  for _, item in ipairs(menu_items) do
    table.insert(content.center, format_menu_item(item, width))
  end
  
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
        
        -- Refresh menu ext

