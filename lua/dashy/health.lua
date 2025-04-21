---@mod dashy.health Health check for Dashy
---@brief [[
Provides health check functionality for Dashy, ensuring all dependencies
and requirements are met.
]]

local M = {}

-- Check Neovim version
---@return boolean ok Whether the Neovim version is compatible
local function check_nvim_version()
  local version = vim.version()
  local required = {0, 10, 0}
  
  if version.major < required[1] or
     (version.major == required[1] and version.minor < required[2]) or
     (version.major == required[1] and version.minor == required[2] and version.patch < required[3]) then
    return false
  end
  
  return true
end

-- Check for required dependencies
---@return table deps Table of dependencies and their status
local function check_dependencies()
  local deps = {
    nvim_web_devicons = false,
    telescope = false,
  }
  
  -- Check for nvim-web-devicons
  local has_devicons, _ = pcall(require, "nvim-web-devicons")
  deps.nvim_web_devicons = has_devicons
  
  -- Check for telescope
  local has_telescope, _ = pcall(require, "telescope.builtin")
  deps.telescope = has_telescope
  
  return deps
end

-- Check for required directories
---@return table dirs Table of directories and their status
local function check_directories()
  local dirs = {
    data = false,
    config = false,
  }
  
  -- Check data directory
  local data_dir = vim.fn.stdpath("data") .. "/dashy"
  if vim.fn.isdirectory(data_dir) == 1 then
    dirs.data = true
  end
  
  -- Check config directory
  local config_dir = vim.fn.stdpath("config")
  if vim.fn.isdirectory(config_dir) == 1 then
    dirs.config = true
  end
  
  return dirs
end

-- Run health check
---@return table health Health check results
function M.check()
  local health = {
    ok = true,
    nvim_version = check_nvim_version(),
    dependencies = check_dependencies(),
    directories = check_directories(),
    issues = {},
  }
  
  -- Check Neovim version
  if not health.nvim_version then
    health.ok = false
    table.insert(health.issues, "Neovim version 0.10.0 or higher is required")
  end
  
  -- Check directories
  if not health.directories.data then
    table.insert(health.issues, "Data directory not found: " .. vim.fn.stdpath("data") .. "/dashy")
  end
  
  if not health.directories.config then
    table.insert(health.issues, "Config directory not found: " .. vim.fn.stdpath("config"))
  end
  
  -- Add warnings for optional dependencies
  if not health.dependencies.nvim_web_devicons then
    table.insert(health.issues, "nvim-web-devicons not found (optional, for file icons)")
  end
  
  if not health.dependencies.telescope then
    table.insert(health.issues, "telescope.nvim not found (optional, for file finding)")
  end
  
  return health
end

-- Report health check results
function M.report()
  local health = M.check()
  
  if not health.ok then
    vim.notify("Dashy health check failed:", vim.log.levels.ERROR)
    for _, issue in ipairs(health.issues) do
      vim.notify("  - " .. issue, vim.log.levels.ERROR)
    end
    return false
  end
  
  if #health.issues > 0 then
    vim.notify("Dashy health check warnings:", vim.log.levels.WARN)
    for _, issue in ipairs(health.issues) do
      vim.notify("  - " .. issue, vim.log.levels.WARN)
    end
  else
    vim.notify("Dashy health check passed", vim.log.levels.INFO)
  end
  
  return true
end

return M

