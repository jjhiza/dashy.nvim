---@mod dashy.features Feature management for Dashy
---@brief [[
-- Handles loading and managing features like sessions, project history,
-- recent files, and custom shortcuts.
-- ]]

local M = {}

-- Get the safe require utility from the main module
local safe_require = require("dashy").safe_require

-- Feature registry
---@type table<string, boolean>
M.enabled_features = {}

-- Initialize features based on configuration
---@param config table Configuration options
function M.init(config)
  -- Load enabled features
  local features = config.features or {}
  
  -- Initialize session management if enabled
  if features.sessions ~= false then
    local sessions = safe_require("dashy.features.sessions")
    if sessions then
      sessions.setup(config.sessions or {})
      M.enabled_features.sessions = true
    end
  end
  
  -- Initialize project history if enabled
  if features.project_history ~= false then
    local projects = safe_require("dashy.features.projects")
    if projects then
      projects.setup(config.project_history or {})
      M.enabled_features.project_history = true
    end
  end
  
  -- Initialize recent files if enabled
  if features.recent_files ~= false then
    local recent = safe_require("dashy.features.recent")
    if recent then
      recent.setup(config.recent_files or {})
      M.enabled_features.recent_files = true
    end
  end
  
  -- Initialize custom shortcuts if enabled
  if features.shortcuts ~= false then
    local shortcuts = safe_require("dashy.features.shortcuts")
    if shortcuts then
      shortcuts.setup(config.shortcuts or {})
      M.enabled_features.shortcuts = true
    end
  end
end

-- Get feature data for rendering
---@param feature string The feature name
---@return table|nil data The feature data or nil if not available
function M.get_feature_data(feature)
  if not M.enabled_features[feature] then
    return nil
  end
  
  local feature_module = safe_require("dashy.features." .. feature)
  if not feature_module then
    return nil
  end
  
  return feature_module.get_data()
end

return M 