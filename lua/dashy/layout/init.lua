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
---@field had_neotree boolean Whether Neotree was open before dashboard was opened
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
  had_neotree = false,
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
  return state.is_visible and 
         state.win_id ~= nil and 
         api.nvim_win_is_valid(state.win_id) and
         state.buf_id ~= nil and
         api.nvim_buf_is_valid(state.buf_id)
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
  -- Set window options while preserving notification visibility
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
  
  -- Keep winblend at 0 to ensure readability
  api.nvim_win_set_option(win_id, "winblend", 0)
  
  -- Set window-local keymaps
  local keymaps = safe_require("dashy.keymaps")
  if keymaps then
    keymaps.setup_dashboard_win_keymaps(win_id)
  end
end

-- Check if Neotree is open
---@return boolean is_open Whether Neotree is open
local function is_neotree_open()
  -- Check for Neotree windows
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    if api.nvim_buf_is_valid(buf) then
      local filetype = api.nvim_buf_get_option(buf, "filetype")
      if filetype == "neo-tree" then
        return true
      end
    end
  end
  return false
end

-- Close Neotree if it's open
---@return boolean was_open Whether Neotree was open and closed
local function close_neotree()
  -- Check if Neotree is loaded
  local has_neotree = pcall(require, "neo-tree")
  if not has_neotree then
    return false
  end
  
  -- Check if Neotree is open
  local neotree_open = is_neotree_open()
  if neotree_open then
    -- Close Neotree
    vim.cmd("Neotree close")
    return true
  end
  
  return false
end

-- Reopen Neotree if it was open
---@param was_open boolean Whether Neotree was open before
local function reopen_neotree(was_open)
  if not was_open then
    return
  end
  
  -- Check if Neotree is loaded
  local has_neotree = pcall(require, "neo-tree")
  if not has_neotree then
    return
  end
  
  -- Reopen Neotree
  vim.cmd("Neotree show")
end

-- Create the dashboard window
---@return number? win_id The created window ID or nil if creation failed
local function create_window()
  -- Check if dashboard is already visible
  if M.is_visible() then
    vim.notify("Dashboard is already visible", vim.log.levels.WARN)
    return state.win_id
  end
  
  -- Check if Neotree is open and close it
  state.had_neotree = close_neotree()
  
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
  
  -- Store dimensions - using the entire viewport
  local dimensions = {
    width = api.nvim_get_option_value("columns", {}),
    height = api.nvim_get_option_value("lines", {}) - 1, -- Subtract command line
    row = 0,
    col = 0,
  }
  
  -- Store dimensions
  state.dimensions = dimensions
  
  -- Use the current window instead of creating a floating window
  local current_win = api.nvim_get_current_win()
  api.nvim_win_set_buf(current_win, buf_id)
  local win_id = current_win
  
  if not win_id then
    vim.notify("Failed to set dashboard buffer to window", vim.log.levels.ERROR)
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
    vim.notify("Invalid buffer ID", vim.log.levels.ERROR)
    return
  end
  
  -- Get the current theme
  local theme_name = theme_manager.get_current_theme()
  if not theme_name then
    vim.notify("No theme selected", vim.log.levels.ERROR)
    return
  end
  
  -- Apply theme to buffer
  theme_manager.apply_to_buffer(buf_id, theme_name)
end

-- Create the dashboard
---@return boolean success Whether creation was successful
function M.create()
  -- Check if dashboard is already visible
  if M.is_visible() then
    vim.notify("Dashboard is already visible", vim.log.levels.WARN)
    return true
  end
  
  -- Create the window
  local win_id = create_window()
  if not win_id then
    return false
  end
  
  -- Populate content
  populate_content(state.buf_id)
  
  -- Set up autocmd to reset state when leaving the dashboard
  local augroup = api.nvim_create_augroup("DashyRestore", { clear = true })
  
  -- Reset state when leaving the dashboard window
  api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    buffer = state.buf_id,
    callback = function()
      if state.prev_win_id and api.nvim_win_is_valid(state.prev_win_id) then
        restore_window_options(state.prev_win_id)
      end
    end,
  })
  
  -- Reset state when an action is performed from the dashboard
  api.nvim_create_autocmd("BufLeave", {
    group = augroup,
    buffer = state.buf_id,
    callback = function()
      -- Reset the state after a short delay to ensure we don't interfere with actions
      vim.defer_fn(function()
        if state.buf_id and not api.nvim_buf_is_valid(state.buf_id) then
          -- Buffer is no longer valid, so reset the state
          state.win_id = nil
          state.buf_id = nil
          state.is_visible = false
          api.nvim_del_augroup_by_name("DashyRestore")
        end
      end, 100)
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
  
  -- Store current window and buffer IDs
  local current_win_id = state.win_id
  local current_buf_id = state.buf_id
  local had_neotree = state.had_neotree
  
  -- Reset state before closing window to avoid recursion
  state.win_id = nil
  state.buf_id = nil
  state.is_visible = false
  state.had_neotree = false
  
  -- First create a new buffer to switch to
  local new_buf = api.nvim_create_buf(true, true)
  
  -- Switch the window to the new buffer
  if api.nvim_win_is_valid(current_win_id) then
    api.nvim_win_set_buf(current_win_id, new_buf)
  end
  
  -- Delete the dashboard buffer
  if api.nvim_buf_is_valid(current_buf_id) then
    api.nvim_buf_delete(current_buf_id, { force = true })
  end
  
  -- Restore Neotree if it was open before
  vim.defer_fn(function()
    reopen_neotree(had_neotree)
  end, 50) -- Small delay to ensure the buffer change is complete
  
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

