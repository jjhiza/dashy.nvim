---@mod dashy.utils Utility functions for Dashy
---@brief [[
-- Provides common utility functions used across the Dashy plugin.
-- ]]

local M = {}

-- Check if a value is nil or empty
---@param value any The value to check
---@return boolean is_empty Whether the value is nil or empty
function M.is_empty(value)
  if value == nil then
    return true
  end
  
  if type(value) == "string" then
    return value == ""
  end
  
  if type(value) == "table" then
    return next(value) == nil
  end
  
  return false
end

-- Deep copy a table
---@param tbl table The table to copy
---@return table copy The copied table
function M.deep_copy(tbl)
  if type(tbl) ~= "table" then
    return tbl
  end
  
  local copy = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      copy[k] = M.deep_copy(v)
    else
      copy[k] = v
    end
  end
  
  return copy
end

-- Merge two tables recursively
---@param t1 table First table
---@param t2 table Second table
---@return table merged The merged table
function M.deep_merge(t1, t2)
  local merged = M.deep_copy(t1)
  
  for k, v in pairs(t2) do
    if type(v) == "table" and type(merged[k]) == "table" then
      merged[k] = M.deep_merge(merged[k], v)
    else
      merged[k] = v
    end
  end
  
  return merged
end

-- Get a value from a nested table using a dot-separated path
---@param tbl table The table to search in
---@param path string The dot-separated path
---@return any value The value at the path, or nil if not found
function M.get_nested(tbl, path)
  local keys = vim.split(path, ".", { plain = true })
  local current = tbl

  for _, key in ipairs(keys) do
    if type(current) ~= "table" then
      return nil
    end
    current = current[key]
    if current == nil then
      return nil
    end
  end

  return current
end

-- Set a value in a nested table using a dot-separated path
---@param tbl table The table to modify
---@param path string The dot-separated path
---@param value any The value to set
function M.set_nested(tbl, path, value)
  local keys = vim.split(path, ".", { plain = true })
  local current = tbl

  for i = 1, #keys - 1 do
    local key = keys[i]
    if current[key] == nil then
      current[key] = {}
    elseif type(current[key]) ~= "table" then
      current[key] = {}
    end
    current = current[key]
  end

  current[keys[#keys]] = value
end

return M 