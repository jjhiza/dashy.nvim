---@mod dashy.layout Layout management for Dashy
---@brief [[
-- Handles window creation, positioning, and lifecycle management for the Dashy dashboard.
-- Provides responsive rendering, ultrawide monitor support, and proper window cleanup.
-- ]]

local api = vim.api
local uv = vim.uv

-- Module definition
---@class DashyLayout
local M = {}

-- Store window and buffer state
---@class DashyLayoutState
---@field win_id? number Window ID of the dashboard
---@field buf_id? number Buffer ID of the dashboard
---@field prev_win_id? number Previous window ID before dashboard was opened
---@field prev_buf_id? number Previous buffer ID before dashboard was opened
---@field win_opts table Window options saved before dashboard was created
---@field is_visible boolean Whether the dashboard is currently visible
---@field dimensions {width: number, height: number, row: number, col: number} Current dashboard dimensions
local state = {
  win_id = nil,
  buf_id = nil,
  prev_win_id = nil,
  prev_buf_id = nil,
  win_opts = {},
  is_visible = false,
  dimensions = {
    width = 0,
    height = 0,
    row = 0,
    col = 0,
  },
}

-- Dashboard content (to be populated by theme)
---@class DashyContent
---@field header string[] Header lines
---@field center string[] Center content lines
---@field footer string[] Footer lines
local content = {
  header = {},
  center = {},
  footer = {},
}

-- Get the safe require utility from the main module
local safe_require = require("dashy").safe_require

-- Get theme manager
local theme_manager = require("dashy.theme")

-- Check if dashboard is visible
---@return boolean is_visible Whether the dashboard is currently visible
function M.is_visible()
  return state.is_visible and state.win_id ~= nil and api.nvim_win_is_valid(state.win_id)
end

-- Get the current state
---@return DashyLayoutState
function M.get_state()
  return state
end

-- Save window options to restore later
---@param win_id number Window ID
local function save_window_options(win_id)
  state.win_opts = {
    statusline = vim.wo[win_id].statusline,
    fillchars = vim.wo[win_id].fillchars,
    winhl = vim.wo[win_id].winhl,
    number = vim.wo[win_id].number,
    relativenumber = vim.wo[win_id].relativenumber,
    cursorline = vim.wo[win_id].cursorline,
    cursorcolumn = vim.wo[win_id].cursorcolumn,
    foldcolumn = vim.wo[win_id].foldcolumn,
    signcolumn = vim.wo[win_id].signcolumn,
    colorcolumn = vim.wo[win_id].colorcolumn,
  }
end

-- Restore window options
---@param win_id number Window ID
local function restore_window_options(win_id)
  if not api.nvim_win_is_valid(win_id) then
    return
  end

  vim.wo[win_id].statusline = state.win_opts.statusline
  vim.wo[win_id].fillchars = state.win_opts.fillchars
  vim.wo[win_id].winhl = state.win_opts.winhl
  vim.wo[win_id].number = state.win_opts.number
  vim.wo[win_id].relativenumber = state.win_opts.relativenumber
  vim.wo[win_id].cursorline = state.win_opts.cursorline
  vim.wo[win_id].cursorcolumn = state.win_opts.cursorcolumn
  vim.wo[win_id].foldcolumn = state.win_opts.foldcolumn
  vim.wo[win_id].signcolumn = state.win_opts.signcolumn
  vim.wo[win_id].colorcolumn = state.win_opts.colorcolumn
end

-- Set buffer options for the dashboard
---@param buf_id number Buffer ID
local function setup_buffer_options(buf_id)
  api.nvim_buf_set_option(buf_id, "buftype", "nofile")
  api.nvim_buf_set_option(buf_id, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf_id, "buflisted", true) -- Make it listed so it's interactive
  api.nvim_buf_set_option(buf_id, "swapfile", false)
  api.nvim_buf_set_option(buf_id, "modifiable", false)
  api.nvim_buf_set_option(buf_id, "filetype", "dashboard")
  api.nvim_buf_set_option(buf_id, "modified", false)
  api.nvim_buf_set_option(buf_id, "readonly", false) -- Make it editable for interaction
  
  -- Set buffer keymaps
  local keymaps = safe_require("dashy.keymaps")
  if keymaps then
    keymaps.setup_dashboard_keymaps(buf_id)
  end
end

-- Set window options for the dashboard
---@param win_id number Window ID
local function setup_window_options(win_id)
  -- Set window options for full-screen mode
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
  api.nvim_win_set_option(win_id, "winhl", "Normal:DashboardNormal,EndOfBuffer:DashboardEndOfBuffer")
  
  -- Set window-local highlights
  api.nvim_win_set_option(win_id, "winblend", 0)
  
  -- Set window-local keymaps
  local keymaps = safe_require("dashy.keymaps")
  if keymaps then
    keymaps.setup_dashboard_win_keymaps(win_id)
  end
end

-- Create the dashboard window
---@return number? win_id The created window ID or nil if creation failed
local function create_window()
  -- Save current window and buffer
  state.prev_win_id = api.nvim_get_current_win()
  state.prev_buf_id = api.nvim_win_get_buf(state.prev_win_id)
  
  -- Save window options
  save_window_options(state.prev_win_id)
  
  -- Create a new buffer
  local buf_id = api.nvim_create_buf(false, true)
  if not buf_id then
    vim.notify("Failed to create dashboard buffer", vim.log.levels.ERROR)
    return nil
  end
  
  -- Set buffer options
  setup_buffer_options(buf_id)
  
  -- For full-screen mode, we use the entire editor area
  local dimensions = {
    width = api.nvim_win_get_width(0),
    height = api.nvim_win_get_height(0),
    row = 0,
    col = 0,
  }
  
  -- Store dimensions
  state.dimensions = dimensions
  
  -- Create the window as a full-screen buffer
  local win_id = api.nvim_open_win(buf_id, true, {
    relative = "editor",
    width = dimensions.width,
    height = dimensions.height,
    row = dimensions.row,
    col = dimensions.col,
    style = "minimal",
    border = "none",
  })
  
  if not win_id then
    vim.notify("Failed to create dashboard window", vim.log.levels.ERROR)
    api.nvim_buf_delete(buf_id, { force = true })
    return nil
  end
  
  -- Set window options
  setup_window_options(win_id)
  
  -- Store window and buffer IDs
  state.win_id = win_id
  state.buf_id = buf_id
  state.is_visible = true
  
  return win_id
end

-- Populate content in the buffer
---@param buf_id number Buffer ID
local function populate_content(buf_id)
  -- Check if buffer is valid
  if not api.nvim_buf_is_valid(buf_id) then
    return
  end
  
  -- Apply theme to buffer
  theme_manager.apply_to_buffer(buf_id)
end

-- Create the dashboard
---@return boolean success Whether creation was successful
function M.create()
  -- Check if dashboard is already visible
  if M.is_visible() then
    return true
  end
  
  -- Create the window
  local win_id = create_window()
  if not win_id then
    return false
  end
  
  -- Populate content
  populate_content(state.buf_id)
  
  -- Set up autocmd to restore window options when leaving the dashboard
  local augroup = api.nvim_create_augroup("DashyRestore", { clear = true })
  api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    pattern = tostring(win_id),
    callback = function()
      if state.prev_win_id and api.nvim_win_is_valid(state.prev_win_id) then
        restore_window_options(state.prev_win_id)
      end
    end,
  })
  
  return true
end

-- Destroy the dashboard
---@return boolean success Whether destruction was successful
function M.destroy()
  -- Check if dashboard is visible
  if not M.is_visible() then
    return true
  end
  
  -- Close the window
  if api.nvim_win_is_valid(state.win_id) then
    api.nvim_win_close(state.win_id, true)
  end
  
  -- Delete the buffer
  if api.nvim_buf_is_valid(state.buf_id) then
    api.nvim_buf_delete(state.buf_id, { force = true })
  end
  
  -- Reset state
  state.win_id = nil
  state.buf_id = nil
  state.is_visible = false
  
  return true
end

-- Redraw the dashboard
---@return boolean success Whether redraw was successful
function M.redraw()
  -- Check if dashboard is visible
  if not M.is_visible() then
    return false
  end
  
  -- Populate content
  populate_content(state.buf_id)
  
  return true
end

-- Return the module
return M

