---@mod dashy.features.projects Project history management for Dashy
---@brief [[
Handles project history functionality, including tracking recently opened projects,
git integration, and project statistics.
]]

local api = vim.api
local uv = vim.uv
local fn = vim.fn

local M = {}

-- Default configuration
M.config = {
  enabled = true,
  max_entries = 10,
  track_git_branches = true,
  save_project_stats = true,
  projects_file = fn.stdpath("data") .. "/dashy/projects.json",
  display_type = "grid", -- or "list"
}

-- Project history cache
M.projects = {}

-- Setup project history
---@param opts table Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Create data directory if it doesn't exist
  local data_dir = fn.fnamemodify(M.config.projects_file, ":h")
  if not uv.fs_stat(data_dir) then
    fn.mkdir(data_dir, "p")
  end
  
  -- Load existing project history
  M.load_projects()
  
  -- Set up autocommands for project tracking
  local group = api.nvim_create_augroup("DashyProjects", { clear = true })
  
  -- Track directory changes
  api.nvim_create_autocmd("DirChanged", {
    group = group,
    callback = function()
      M.update_current_project()
    end,
    desc = "Track project directory changes",
  })
  
  -- Update project stats periodically
  if M.config.save_project_stats then
    api.nvim_create_autocmd("BufWritePost", {
      group = group,
      callback = function()
        M.update_project_stats()
      end,
      desc = "Update project statistics",
    })
  end
end

-- Check if directory is a git repository
---@param dir string Directory path
---@return boolean is_git Whether the directory is a git repository
local function is_git_repo(dir)
  local git_dir = dir .. "/.git"
  return uv.fs_stat(git_dir) ~= nil
end

-- Get current git branch
---@param dir string Directory path
---@return string|nil branch Current git branch name
local function get_git_branch(dir)
  local handle = io.popen("git -C " .. fn.shellescape(dir) .. " branch --show-current 2>/dev/null")
  if not handle then
    return nil
  end
  
  local branch = handle:read("*l")
  handle:close()
  
  return branch
end

-- Load projects from disk
function M.load_projects()
  if not uv.fs_stat(M.config.projects_file) then
    M.projects = {}
    return
  end
  
  local content = fn.readfile(M.config.projects_file)
  if not content or #content == 0 then
    M.projects = {}
    return
  end
  
  local ok, data = pcall(vim.json.decode, content[1])
  if not ok or type(data) ~= "table" then
    M.projects = {}
    return
  end
  
  M.projects = data
end

-- Save projects to disk
local function save_projects()
  local data = vim.json.encode(M.projects)
  fn.writefile({data}, M.config.projects_file)
end

-- Update current project information
function M.update_current_project()
  local cwd = fn.getcwd()
  local project = {
    path = cwd,
    name = fn.fnamemodify(cwd, ":t"),
    last_opened = os.time(),
    stats = {
      files = 0,
      lines = 0,
      last_modified = os.time(),
    },
  }
  
  -- Check if it's a git repository
  if M.config.track_git_branches and is_git_repo(cwd) then
    project.git = {
      branch = get_git_branch(cwd),
      last_commit = os.time(),
    }
  end
  
  -- Update or add project
  local updated = false
  for i, p in ipairs(M.projects) do
    if p.path == cwd then
      -- Update existing project
      M.projects[i] = vim.tbl_extend("force", p, project)
      updated = true
      break
    end
  end
  
  if not updated then
    -- Add new project
    table.insert(M.projects, 1, project)
    
    -- Keep only max_entries
    if #M.projects > M.config.max_entries then
      table.remove(M.projects)
    end
  end
  
  -- Save changes
  save_projects()
end

-- Update project statistics
function M.update_project_stats()
  local cwd = fn.getcwd()
  
  -- Find current project
  for i, project in ipairs(M.projects) do
    if project.path == cwd then
      -- Count files and lines
      local stats = {
        files = 0,
        lines = 0,
        last_modified = os.time(),
      }
      
      -- Use ripgrep to count files and lines
      local handle = io.popen(string.format(
        "rg --files %s | wc -l",
        fn.shellescape(cwd)
      ))
      if handle then
        stats.files = tonumber(handle:read("*l")) or 0
        handle:close()
      end
      
      handle = io.popen(string.format(
        "rg --files %s | xargs wc -l 2>/dev/null | tail -n1",
        fn.shellescape(cwd)
      ))
      if handle then
        stats.lines = tonumber(handle:read("*l"):match("(%d+)%s+total")) or 0
        handle:close()
      end
      
      -- Update project stats
      M.projects[i].stats = stats
      save_projects()
      break
    end
  end
end

-- Open a project
---@param path string Project path
function M.open_project(path)
  if not uv.fs_stat(path) then
    vim.notify("Project directory not found: " .. path, vim.log.levels.ERROR)
    return false
  end
  
  -- Change to project directory
  vim.cmd("cd " .. fn.fnameescape(path))
  return true
end

-- Get project data for display
---@return table Data for rendering projects in the dashboard
function M.get_data()
  return {
    type = M.config.display_type,
    items = M.projects,
    actions = {
      open = M.open_project,
    },
  }
end

return M 