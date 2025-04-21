---@mod dashy.features.sessions Session management for Dashy
---@brief [[
-- Handles session management functionality, including saving, loading,
-- and displaying available sessions.
-- ]]

local api = vim.api
local uv = vim.uv
local fn = vim.fn

local M = {}

-- Default configuration
M.config = {
  enabled = true,
  max_entries = 5,
  save_on_exit = true,
  session_dir = fn.stdpath("data") .. "/dashy/sessions",
  display_type = "list", -- or "grid"
}

-- Session cache
M.sessions = {}

-- Setup session management
---@param opts table Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Create session directory if it doesn't exist
  local session_dir = M.config.session_dir
  if not uv.fs_stat(session_dir) then
    fn.mkdir(session_dir, "p")
  end
  
  -- Load existing sessions
  M.load_sessions()
  
  -- Set up autocommands for session management
  local group = api.nvim_create_augroup("DashySessions", { clear = true })
  
  if M.config.save_on_exit then
    api.nvim_create_autocmd("VimLeavePre", {
      group = group,
      callback = function()
        M.save_current_session()
      end,
      desc = "Save session on exit",
    })
  end
end

-- Load existing sessions from disk
function M.load_sessions()
  local session_dir = M.config.session_dir
  local sessions = {}
  
  -- List session files
  local handle = uv.fs_scandir(session_dir)
  if not handle then
    return
  end
  
  while true do
    local name, type = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    
    if type == "file" and vim.endswith(name, ".vim") then
      local session_name = name:sub(1, -5) -- Remove .vim extension
      local path = session_dir .. "/" .. name
      local stat = uv.fs_stat(path)
      
      if stat then
        table.insert(sessions, {
          name = session_name,
          path = path,
          last_modified = stat.mtime.sec,
        })
      end
    end
  end
  
  -- Sort sessions by last modified time
  table.sort(sessions, function(a, b)
    return a.last_modified > b.last_modified
  end)
  
  -- Keep only the most recent sessions based on max_entries
  if #sessions > M.config.max_entries then
    for i = M.config.max_entries + 1, #sessions do
      uv.fs_unlink(sessions[i].path)
    end
    sessions = vim.list_slice(sessions, 1, M.config.max_entries)
  end
  
  M.sessions = sessions
end

-- Save current session
---@param name? string Optional session name (defaults to current directory name)
function M.save_current_session(name)
  -- Get session name from current directory if not provided
  if not name then
    name = fn.fnamemodify(fn.getcwd(), ":t")
  end
  
  -- Clean session name
  name = name:gsub("[^%w_-]", "_")
  
  local session_file = M.config.session_dir .. "/" .. name .. ".vim"
  
  -- Create session
  local cmd = "mksession! " .. fn.fnameescape(session_file)
  local ok, err = pcall(vim.cmd, cmd)
  
  if not ok then
    vim.notify("Failed to save session: " .. err, vim.log.levels.ERROR)
    return false
  end
  
  -- Reload sessions list
  M.load_sessions()
  return true
end

-- Load a session
---@param name string Session name or path
function M.load_session(name)
  local session_path
  
  -- Check if name is a full path
  if vim.startswith(name, M.config.session_dir) then
    session_path = name
  else
    session_path = M.config.session_dir .. "/" .. name .. ".vim"
  end
  
  -- Check if session exists
  if not uv.fs_stat(session_path) then
    vim.notify("Session not found: " .. name, vim.log.levels.ERROR)
    return false
  end
  
  -- Load session
  local cmd = "source " .. fn.fnameescape(session_path)
  local ok, err = pcall(vim.cmd, cmd)
  
  if not ok then
    vim.notify("Failed to load session: " .. err, vim.log.levels.ERROR)
    return false
  end
  
  return true
end

-- Delete a session
---@param name string Session name
function M.delete_session(name)
  local session_path = M.config.session_dir .. "/" .. name .. ".vim"
  
  -- Check if session exists
  if not uv.fs_stat(session_path) then
    vim.notify("Session not found: " .. name, vim.log.levels.ERROR)
    return false
  end
  
  -- Delete session file
  local ok = uv.fs_unlink(session_path)
  if not ok then
    vim.notify("Failed to delete session: " .. name, vim.log.levels.ERROR)
    return false
  end
  
  -- Reload sessions list
  M.load_sessions()
  return true
end

-- Get session data for display
---@return table Data for rendering sessions in the dashboard
function M.get_data()
  return {
    type = M.config.display_type,
    items = M.sessions,
    actions = {
      load = M.load_session,
      delete = M.delete_session,
      save = M.save_current_session,
    },
  }
end

return M 