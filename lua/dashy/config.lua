---@mod dashy.config Configuration management for Dashy
---@brief [[
Handles configuration validation, processing, and access for the Dashy plugin.
Uses modern Neovim APIs and provides robust type checking and error handling.
]]

local api = vim.api
local utils = require("dashy.utils")

-- Module definition
---@class DashyConfig
local M = {}

-- Private storage for current configuration
---@type DashySetupOptions
local config = {}

-- Schema for validating configuration values
---@type table<string, {validate: function, message: string}>
local schema = {
  theme = {
    validate = function(v)
      return type(v) == "string"
    end,
    message = "theme must be a string",
  },
  hide = {
    validate = function(v)
      return type(v) == "table"
    end,
    message = "hide must be a table",
  },
  ["hide.statusline"] = {
    validate = function(v)
      return type(v) == "boolean"
    end,
    message = "hide.statusline must be a boolean",
  },
  ["hide.tabline"] = {
    validate = function(v)
      return type(v) == "boolean"
    end,
    message = "hide.tabline must be a boolean",
  },
  ["hide.winbar"] = {
    validate = function(v)
      return type(v) == "boolean"
    end,
    message = "hide.winbar must be a boolean",
  },
  autoopen = {
    validate = function(v)
      return type(v) == "boolean"
    end,
    message = "autoopen must be a boolean",
  },
  shortcut_type = {
    validate = function(v)
      return v == "letter" or v == "number"
    end,
    message = "shortcut_type must be either 'letter' or 'number'",
  },
  shortcut_style = {
    validate = function(v)
      return v == "icon" or v == "text"
    end,
    message = "shortcut_style must be either 'icon' or 'text'",
  },
  sections = {
    validate = function(v)
      return type(v) == "table"
    end,
    message = "sections must be a table",
  },
}

-- Validate a specific configuration value
---@param key string The configuration key
---@param value any The value to validate
---@return boolean valid Whether the value is valid
---@return string? error Error message if invalid
local function validate_value(key, value)
  local validator = schema[key]
  if not validator then
    return true
  end

  if not validator.validate(value) then
    return false, validator.message
  end

  return true
end

-- Validate the entire configuration
---@param cfg DashySetupOptions The configuration to validate
---@return boolean valid Whether the configuration is valid
---@return string? error Error message if invalid
local function validate_config(cfg)
  -- Create a flat map of all paths to validate
  local to_validate = {}
  
  -- Add top-level keys
  for k, _ in pairs(schema) do
    if not string.find(k, ".", 1, true) then
      to_validate[k] = true
    end
  end
  
  -- Add nested keys if their parent exists
  for k, _ in pairs(schema) do
    if string.find(k, ".", 1, true) then
      local parent = k:match("^([^.]+)%.")
      if cfg[parent] ~= nil then
        to_validate[k] = true
      end
    end
  end
  
  -- Validate each path
  for path, _ in pairs(to_validate) do
    local value = utils.get_nested(cfg, path)
    if value ~= nil then
      local valid, err = validate_value(path, value)
      if not valid then
        return false, string.format("Invalid configuration: %s", err)
      end
    end
  end
  
  return true
end

-- Initialize the configuration
---@param cfg DashySetupOptions The configuration to initialize
---@return boolean success Whether initialization was successful
function M.init(cfg)
  local valid, err = validate_config(cfg)
  if not valid then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end
  
  -- Store the configuration
  config = utils.deep_copy(cfg)
  
  -- Setup highlight groups
  M.setup_highlights()
  
  return true
end

-- Setup highlight groups based on configuration
function M.setup_highlights()
  -- Define highlight group commands
  local highlight_cmds = {
    -- Define dashy highlight groups linked to default groups
    "highlight default link DashyHeader Title",
    "highlight default link DashySubHeader Comment",
    "highlight default link DashyFooter Comment",
    "highlight default link DashyShortcut Keyword",
    "highlight default link DashyIcon Special",
    "highlight default link DashyDesc String",
  }
  
  -- Apply all highlight commands
  for _, cmd in ipairs(highlight_cmds) do
    vim.cmd(cmd)
  end
end

-- Get the entire configuration or a specific value
---@param key? string The configuration key to get (optional)
---@return any value The configuration value, or the entire config if no key is provided
function M.get(key)
  if not key then
    return utils.deep_copy(config)
  end
  
  return utils.deep_copy(utils.get_nested(config, key))
end

-- Set a configuration value
---@param key string The configuration key to set
---@param value any The value to set
---@return boolean success Whether the operation was successful
function M.set(key, value)
  local valid, err = validate_value(key, value)
  if not valid then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end
  
  utils.set_nested(config, key, utils.deep_copy(value))
  return true
end

-- Update multiple configuration values
---@param updates table<string, any> The updates to apply
---@return boolean success Whether all updates were successful
function M.update(updates)
  -- Validate all updates first
  for key, value in pairs(updates) do
    local valid, err = validate_value(key, value)
    if not valid then
      vim.notify(err, vim.log.levels.ERROR)
      return false
    end
  end
  
  -- Apply all updates
  for key, value in pairs(updates) do
    utils.set_nested(config, key, utils.deep_copy(value))
  end
  
  return true
end

-- Reset configuration to defaults
---@param defaults DashySetupOptions The default configuration
function M.reset(defaults)
  config = utils.deep_copy(defaults)
end

-- Return the module
return M

