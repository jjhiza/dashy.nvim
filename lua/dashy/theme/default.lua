---@mod dashy.theme.default Default theme for Dashy
---@brief [[
-- Provides the default theme for the Dashy dashboard.
-- Based on the Rose Pine Moon theme palette.
-- ]]

local api = vim.api

local M = {}

-- Default theme colors based on Rose Pine Moon
local colors = {
	-- Base colors
	bg = "#232136", -- Base
	fg = "#e0def4", -- Text
	accent = "#c4a7e7", -- Iris
	border = "#393552", -- Overlay

	-- Status colors
	success = "#9ccfd8", -- Foam
	warning = "#f6c177", -- Gold
	error = "#eb6f92", -- Love
	info = "#31748f", -- Pine

	-- Additional semantic colors
	title = "#c4a7e7", -- Iris
	subtitle = "#9ccfd8", -- Foam
	muted = "#6e6a86", -- Muted
	highlight = "#524f67", -- Highlight High

	-- UI element colors
	button_bg = "#2a273f", -- Surface
	button_fg = "#e0def4", -- Text
	button_border = "#393552", -- Overlay

	card_bg = "#2a273f", -- Surface
	card_border = "#393552", -- Overlay

	list_bg = "#2a273f", -- Surface
	list_border = "#393552", -- Overlay

	grid_bg = "#2a273f", -- Surface
	grid_border = "#393552", -- Overlay

	progress_bg = "#2a273f", -- Surface
	progress_fg = "#c4a7e7", -- Iris

	search_bg = "#2a273f", -- Surface
	search_fg = "#e0def4", -- Text
	search_border = "#393552", -- Overlay

	help_bg = "#2a273f", -- Surface
	help_fg = "#e0def4", -- Text
	help_border = "#393552", -- Overlay
}

-- Get theme colors
---@return table
function M.get_colors()
	return colors
end

-- Get menu items
---@return table
function M.get_menu_items()
	return {
		{ desc = "Find File", action = "Telescope find_files" },
		{ desc = "Live Grep", action = "Telescope live_grep" },
		{ desc = "Recent Files", action = "Telescope oldfiles" },
		{ desc = "Config", action = "edit ~/.config/nvim/init.lua" },
		{ desc = "Lazy", action = "Lazy" },
		{ desc = "Quit", action = "bdelete" },
	}
end

-- Get theme content
---@param bufnr number Buffer ID
---@param winid number Window ID
---@return table? content The theme content
function M.get_content(bufnr, winid)
	-- Get window dimensions
	local width = api.nvim_win_get_width(winid)
	local height = api.nvim_win_get_height(winid)

	-- Generate content
	local content = {
		header = {
			"██████╗   █████╗  ███████╗ ██╗  ██╗ ██╗   ██╗",
			"██╔══██╗ ██╔══██╗ ██╔════╝ ██║  ██║ ╚██╗ ██╔╝",
			"██║  ██║ ███████║ ███████╗ ███████║  ╚████╔╝ ",
			"██║  ██║ ██╔══██║ ╚════██║ ██╔══██║   ╚██╔╝  ",
			"██████╔╝ ██║  ██║ ███████║ ██║  ██║    ██║   ",
			"╚═════╝  ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝    ╚═╝   ",
		},
		center = {
			"[󰮗] Find File",
			"[󰬵] Live Grep",
			"[󰷏] Recent Files",
      -- "[󰚰] Projects", uncomment if using project.nvim, and want to add this menu entry
			"[󰖟] Config",
			"[󰒲] Lazy",
			"[󰈆] Quit",
		},
		footer = {
			"Neovim Dashboard",
			"Press 'q' to close",
		},
	}

	return content
end

-- Apply highlights to the dashboard
---@param buf_id number Buffer ID
---@param lines table The content lines
function M.apply_highlights(buf_id, lines)
	-- Calculate positions for highlights
	local header_lines = 6  -- Number of header lines
	local content_start = header_lines + 2  -- Header + spacer
	
	-- Define highlight groups
	local highlight_groups = {}
	
	-- Header highlights (first 6 lines)
	for i = 1, header_lines do
		local line = lines[i]
		local start_col = line:find("[^ ]") - 1  -- Find first non-space character
		local end_col = line:len()
		table.insert(highlight_groups, {
			group = "DashboardHeader",
			line = i - 1,  -- 0-indexed
			col_start = start_col,
			col_end = end_col
		})
	end
	
	-- Menu item highlights
	for i = content_start, content_start + 5 do  -- 6 menu items
		local line = lines[i]
		local icon_end = line:find("]")
		if icon_end then
			-- Highlight icon differently
			table.insert(highlight_groups, {
				group = "DashboardIcon",
				line = i - 1,
				col_start = line:find("[") - 1,
				col_end = icon_end
			})
			
			-- Highlight menu text
			table.insert(highlight_groups, {
				group = "DashboardCenter",
				line = i - 1,
				col_start = icon_end,
				col_end = line:len()
			})
		end
	end
	
	-- Footer highlights
	local footer_start = #lines - 2  -- Last 2 lines
	for i = footer_start, #lines do
		local line = lines[i]
		local start_col = line:find("[^ ]") - 1  -- Find first non-space character
		if start_col < 0 then start_col = 0 end
		table.insert(highlight_groups, {
			group = "DashboardFooter",
			line = i - 1,
			col_start = start_col,
			col_end = line:len()
		})
	end

	-- Apply highlights
	local ns_id = vim.api.nvim_create_namespace("dashy_theme")
	for _, hl in ipairs(highlight_groups) do
		vim.api.nvim_buf_add_highlight(
			buf_id,
			ns_id,
			hl.group,
			hl.line,
			hl.col_start,
			hl.col_end
		)
	end
end

return M
