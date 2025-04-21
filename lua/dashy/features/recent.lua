---@mod dashy.features.recent Recent files management for Dashy
---@brief [[
-- Handles tracking and displaying recently opened files, with support for
-- file type icons and preview.
-- ]]

local api = vim.api
local uv = vim.uv
local fn = vim.fn

local M = {}

-- Default configuration
M.config = {
  enabled = true,
  max_entries = 10,
  exclude_filetypes = {"gitcommit", "gitrebase", "help", "qf"},
  exclude_buftype = {"terminal", "quickfix", "nofile", "help"},
  save_write_times = true,
  recent_file = fn.stdpath("data") .. "/dashy/recent.json",
  display_type = "list", -- or "grid"
  show_icons = true,
}

-- Recent files cache
M.recent_files = {}

-- Setup recent files tracking
---@param opts table Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Create data directory if it doesn't exist
  local data_dir = fn.fnamemodify(M.config.recent_file, ":h")
  if not uv.fs_stat(data_dir) then
    fn.mkdir(data_dir, "p")
  end
  
  -- Load existing recent files
  M.load_recent_files()
  
  -- Set up autocommands for file tracking
  local group = api.nvim_create_augroup("DashyRecent", { clear = true })
  
  -- Track file opens
  api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function()
      M.update_recent_file()
    end,
    desc = "Track recently opened files",
  })
  
  -- Track file writes if enabled
  if M.config.save_write_times then
    api.nvim_create_autocmd("BufWritePost", {
      group = group,
      callback = function()
        M.update_write_time()
      end,
      desc = "Track file write times",
    })
  end
end

-- Check if buffer should be tracked
---@param bufnr number Buffer number
---@return boolean should_track Whether the buffer should be tracked
local function should_track_buffer(bufnr)
  -- Get buffer info
  local buftype = api.nvim_buf_get_option(bufnr, "buftype")
  local filetype = api.nvim_buf_get_option(bufnr, "filetype")
  
  -- Check if buffer type is excluded
  if vim.tbl_contains(M.config.exclude_buftype, buftype) then
    return false
  end
  
  -- Check if file type is excluded
  if vim.tbl_contains(M.config.exclude_filetypes, filetype) then
    return false
  end
  
  -- Get buffer name
  local name = api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end
  
  -- Check if file exists
  if not uv.fs_stat(name) then
    return false
  end
  
  return true
end

-- Load recent files from disk
function M.load_recent_files()
  if not uv.fs_stat(M.config.recent_file) then
    M.recent_files = {}
    return
  end
  
  local content = fn.readfile(M.config.recent_file)
  if not content or #content == 0 then
    M.recent_files = {}
    return
  end
  
  local ok, data = pcall(vim.json.decode, content[1])
  if not ok or type(data) ~= "table" then
    M.recent_files = {}
    return
  end
  
  M.recent_files = data
end

-- Save recent files to disk
local function save_recent_files()
  local data = vim.json.encode(M.recent_files)
  fn.writefile({data}, M.config.recent_file)
end

-- Get file icon if available
---@param filename string File name
---@return string icon File icon or empty string
local function get_file_icon(filename)
  -- Try to use nvim-web-devicons if available
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    local icon = devicons.get_icon(filename, fn.fnamemodify(filename, ":e"))
    if icon then
      return icon .. " "
    end
  end
  return ""
end

-- Update recent file entry
function M.update_recent_file()
  local bufnr = api.nvim_get_current_buf()
  
  -- Check if buffer should be tracked
  if not should_track_buffer(bufnr) then
    return
  end
  
  local name = api.nvim_buf_get_name(bufnr)
  local file = {
    path = name,
    name = fn.fnamemodify(name, ":t"),
    last_opened = os.time(),
    last_written = os.time(),
  }
  
  -- Add icon if enabled
  if M.config.show_icons then
    file.icon = get_file_icon(file.name)
  end
  
  -- Update or add file
  local updated = false
  for i, f in ipairs(M.recent_files) do
    if f.path == name then
      -- Update existing file
      M.recent_files[i] = vim.tbl_extend("force", f, file)
      updated = true
      break
    end
  end
  
  if not updated then
    -- Add new file
    table.insert(M.recent_files, 1, file)
    
    -- Keep only max_entries
    if #M.recent_files > M.config.max_entries then
      table.remove(M.recent_files)
    end
  end
  
  -- Save changes
  save_recent_files()
end

-- Update file write time
function M.update_write_time()
  local bufnr = api.nvim_get_current_buf()
  local name = api.nvim_buf_get_name(bufnr)
  
  -- Find and update file
  for i, file in ipairs(M.recent_files) do
    if file.path == name then
      M.recent_files[i].last_written = os.time()
      save_recent_files()
      break
    end
  end
end

-- Open a file
---@param path string File path
function M.open_file(path)
  if not uv.fs_stat(path) then
    vim.notify("File not found: " .. path, vim.log.levels.ERROR)
    return false
  end
  
  -- Open the file
  vim.cmd("edit " .. fn.fnameescape(path))
  return true
end

-- Get recent files data for display
---@return table Data for rendering recent files in the dashboard
function M.get_data()
  return {
    type = M.config.display_type,
    items = M.recent_files,
    actions = {
      open = M.open_file,
    },
  }
end

return M 