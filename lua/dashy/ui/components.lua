---@mod dashy.ui.components UI components for Dashy
---@brief [[
-- Provides UI components for the Dashy dashboard.
-- Includes buttons, cards, progress bars, and other visual elements.
-- ]]

local api = vim.api

-- Module definition
---@class DashyUIComponents
local M = {}

-- Get the safe require utility from the main module
local safe_require = require("dashy").safe_require

-- Create a button component
---@param text string Button text
---@param key string Key to press
---@param cmd string Command to execute
---@param highlight string Highlight group
---@return string[] lines Button lines
---@return table highlights Button highlights
function M.create_button(text, key, cmd, highlight)
  local lines = {}
  local highlights = {}
  
  -- Button style
  local button_style = {
    left = "╭",
    right = "╮",
    top = "─",
    bottom = "─",
    left_bottom = "╰",
    right_bottom = "╯",
  }
  
  -- Create button lines
  local button_width = vim.fn.strdisplaywidth(text) + 6 -- Add padding
  local top_line = button_style.left .. string.rep(button_style.top, button_width - 2) .. button_style.right
  local text_line = "│ " .. text .. string.rep(" ", button_width - vim.fn.strdisplaywidth(text) - 4) .. "│"
  local bottom_line = button_style.left_bottom .. string.rep(button_style.bottom, button_width - 2) .. button_style.right_bottom
  
  -- Add lines
  table.insert(lines, top_line)
  table.insert(lines, text_line)
  table.insert(lines, bottom_line)
  
  -- Add highlights
  local ns_id = api.nvim_create_namespace("dashy_ui")
  local highlight_group = highlight or "DashboardButton"
  
  -- Highlight the entire button
  table.insert(highlights, {
    ns_id = ns_id,
    line_start = 0,
    line_end = 2,
    col_start = 0,
    col_end = button_width,
    hl_group = highlight_group,
  })
  
  -- Highlight the key
  local key_start = vim.fn.strdisplaywidth(text) + 3
  table.insert(highlights, {
    ns_id = ns_id,
    line_start = 1,
    line_end = 1,
    col_start = key_start,
    col_end = key_start + 1,
    hl_group = "DashboardKey",
  })
  
  return lines, highlights
end

-- Create a card component
---@param title string Card title
---@param content string[] Card content
---@param highlight string Highlight group
---@return string[] lines Card lines
---@return table highlights Card highlights
function M.create_card(title, content, highlight)
  local lines = {}
  local highlights = {}
  
  -- Card style
  local card_style = {
    top_left = "╭",
    top_right = "╮",
    bottom_left = "╰",
    bottom_right = "╯",
    horizontal = "─",
    vertical = "│",
  }
  
  -- Calculate card width
  local card_width = 0
  for _, line in ipairs(content) do
    card_width = math.max(card_width, vim.fn.strdisplaywidth(line))
  end
  card_width = math.max(card_width, vim.fn.strdisplaywidth(title)) + 4 -- Add padding
  
  -- Create card lines
  local top_line = card_style.top_left .. string.rep(card_style.horizontal, card_width - 2) .. card_style.top_right
  local title_line = card_style.vertical .. " " .. title .. string.rep(" ", card_width - vim.fn.strdisplaywidth(title) - 3) .. card_style.vertical
  local separator_line = card_style.vertical .. string.rep(card_style.horizontal, card_width - 2) .. card_style.vertical
  
  -- Add top lines
  table.insert(lines, top_line)
  table.insert(lines, title_line)
  table.insert(lines, separator_line)
  
  -- Add content lines
  for _, line in ipairs(content) do
    local content_line = card_style.vertical .. " " .. line .. string.rep(" ", card_width - vim.fn.strdisplaywidth(line) - 3) .. card_style.vertical
    table.insert(lines, content_line)
  end
  
  -- Add bottom line
  local bottom_line = card_style.bottom_left .. string.rep(card_style.horizontal, card_width - 2) .. card_style.bottom_right
  table.insert(lines, bottom_line)
  
  -- Add highlights
  local ns_id = api.nvim_create_namespace("dashy_ui")
  local highlight_group = highlight or "DashboardCard"
  
  -- Highlight the entire card
  table.insert(highlights, {
    ns_id = ns_id,
    line_start = 0,
    line_end = #lines - 1,
    col_start = 0,
    col_end = card_width,
    hl_group = highlight_group,
  })
  
  -- Highlight the title
  table.insert(highlights, {
    ns_id = ns_id,
    line_start = 1,
    line_end = 1,
    col_start = 2,
    col_end = 2 + vim.fn.strdisplaywidth(title),
    hl_group = "DashboardTitle",
  })
  
  return lines, highlights
end

-- Create a progress bar component
---@param value number Progress value (0-100)
---@param width number Progress bar width
---@param highlight string Highlight group
---@return string[] lines Progress bar lines
---@return table highlights Progress bar highlights
function M.create_progress_bar(value, width, highlight)
  local lines = {}
  local highlights = {}
  
  -- Progress bar style
  local progress_style = {
    left = "[",
    right = "]",
    filled = "█",
    empty = "░",
  }
  
  -- Ensure value is between 0 and 100
  value = math.max(0, math.min(100, value))
  
  -- Calculate filled width
  local filled_width = math.floor((value / 100) * (width - 2))
  local empty_width = width - 2 - filled_width
  
  -- Create progress bar line
  local progress_line = progress_style.left .. string.rep(progress_style.filled, filled_width) .. string.rep(progress_style.empty, empty_width) .. progress_style.right
  
  -- Add line
  table.insert(lines, progress_line)
  
  -- Add highlights
  local ns_id = api.nvim_create_namespace("dashy_ui")
  local highlight_group = highlight or "DashboardProgress"
  
  -- Highlight the entire progress bar
  table.insert(highlights, {
    ns_id = ns_id,
    line_start = 0,
    line_end = 0,
    col_start = 0,
    col_end = width,
    hl_group = highlight_group,
  })
  
  -- Highlight the filled part
  table.insert(highlights, {
    ns_id = ns_id,
    line_start = 0,
    line_end = 0,
    col_start = 1,
    col_end = 1 + filled_width,
    hl_group = "DashboardProgressFilled",
  })
  
  return lines, highlights
end

-- Create a list component
---@param items string[] List items
---@param highlight string Highlight group
---@return string[] lines List lines
---@return table highlights List highlights
function M.create_list(items, highlight)
  local lines = {}
  local highlights = {}
  
  -- List style
  local list_style = {
    bullet = "•",
  }
  
  -- Add items
  for i, item in ipairs(items) do
    local list_line = list_style.bullet .. " " .. item
    table.insert(lines, list_line)
  end
  
  -- Add highlights
  local ns_id = api.nvim_create_namespace("dashy_ui")
  local highlight_group = highlight or "DashboardList"
  
  -- Highlight the entire list
  table.insert(highlights, {
    ns_id = ns_id,
    line_start = 0,
    line_end = #lines - 1,
    col_start = 0,
    col_end = 1000, -- Large enough to cover any line
    hl_group = highlight_group,
  })
  
  -- Highlight the bullets
  for i, _ in ipairs(items) do
    table.insert(highlights, {
      ns_id = ns_id,
      line_start = i - 1,
      line_end = i - 1,
      col_start = 0,
      col_end = 1,
      hl_group = "DashboardBullet",
    })
  end
  
  return lines, highlights
end

-- Create a grid component
---@param items table[] Grid items
---@param cols number Number of columns
---@param highlight string Highlight group
---@return string[] lines Grid lines
---@return table highlights Grid highlights
function M.create_grid(items, cols, highlight)
  local lines = {}
  local highlights = {}
  
  -- Grid style
  local grid_style = {
    top_left = "╭",
    top_right = "╮",
    bottom_left = "╰",
    bottom_right = "╯",
    horizontal = "─",
    vertical = "│",
    cross = "┼",
    top_cross = "┬",
    bottom_cross = "┴",
    left_cross = "├",
    right_cross = "┤",
  }
  
  -- Calculate item width and height
  local item_width = 0
  local item_height = 0
  for _, item in ipairs(items) do
    item_width = math.max(item_width, vim.fn.strdisplaywidth(item.text))
    item_height = math.max(item_height, #item.lines)
  end
  item_width = item_width + 4 -- Add padding
  item_height = item_height + 2 -- Add padding
  
  -- Calculate grid dimensions
  local rows = math.ceil(#items / cols)
  local grid_width = cols * item_width + 1
  local grid_height = rows * item_height + 1
  
  -- Create grid lines
  for row = 0, rows do
    -- Top border of row
    local top_line = ""
    for col = 0, cols do
      if row == 0 and col == 0 then
        top_line = top_line .. grid_style.top_left
      elseif row == 0 and col == cols then
        top_line = top_line .. grid_style.top_right
      elseif row == rows and col == 0 then
        top_line = top_line .. grid_style.bottom_left
      elseif row == rows and col == cols then
        top_line = top_line .. grid_style.bottom_right
      elseif row == 0 then
        top_line = top_line .. grid_style.top_cross
      elseif row == rows then
        top_line = top_line .. grid_style.bottom_cross
      elseif col == 0 then
        top_line = top_line .. grid_style.left_cross
      elseif col == cols then
        top_line = top_line .. grid_style.right_cross
      else
        top_line = top_line .. grid_style.cross
      end
      
      if col < cols then
        top_line = top_line .. string.rep(grid_style.horizontal, item_width - 1)
      end
    end
    table.insert(lines, top_line)
    
    -- Skip content lines for the last row (bottom border)
    if row < rows then
      -- Content lines
      for i = 0, item_height - 2 do
        local content_line = grid_style.vertical
        for col = 0, cols - 1 do
          local item_idx = row * cols + col + 1
          if item_idx <= #items then
            local item = items[item_idx]
            local item_line = ""
            if i < #item.lines then
              item_line = item.lines[i + 1]
            else
              item_line = string.rep(" ", item_width - 2)
            end
            content_line = content_line .. " " .. item_line .. string.rep(" ", item_width - vim.fn.strdisplaywidth(item_line) - 2) .. grid_style.vertical
          else
            content_line = content_line .. string.rep(" ", item_width) .. grid_style.vertical
          end
        end
        table.insert(lines, content_line)
      end
    end
  end
  
  -- Add highlights
  local ns_id = api.nvim_create_namespace("dashy_ui")
  local highlight_group = highlight or "DashboardGrid"
  
  -- Highlight the entire grid
  table.insert(highlights, {
    ns_id = ns_id,
    line_start = 0,
    line_end = #lines - 1,
    col_start = 0,
    col_end = grid_width,
    hl_group = highlight_group,
  })
  
  -- Highlight each item
  for i, item in ipairs(items) do
    local row = math.floor((i - 1) / cols)
    local col = (i - 1) % cols
    
    local start_line = row * item_height + 1
    local start_col = col * item_width + 1
    
    table.insert(highlights, {
      ns_id = ns_id,
      line_start = start_line,
      line_end = start_line + item_height - 2,
      col_start = start_col,
      col_end = start_col + item_width - 1,
      hl_group = item.highlight or "DashboardGridItem",
    })
  end
  
  return lines, highlights
end

-- Apply highlights to a buffer
---@param buf_id number Buffer ID
---@param highlights table[] Highlights to apply
function M.apply_highlights(buf_id, highlights)
  if not api.nvim_buf_is_valid(buf_id) then
    return
  end
  
  -- Clear existing highlights
  for _, ns_id in ipairs(api.nvim_get_namespaces()) do
    if vim.startswith(api.nvim_get_namespace(ns_id).name, "dashy_ui") then
      api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)
    end
  end
  
  -- Apply new highlights
  for _, highlight in ipairs(highlights) do
    api.nvim_buf_add_highlight(
      buf_id,
      highlight.ns_id,
      highlight.hl_group,
      highlight.line_start,
      highlight.col_start,
      highlight.col_end
    )
  end
end

return M 