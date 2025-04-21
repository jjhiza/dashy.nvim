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
			"  ██████╗   █████╗  ███████╗ ██╗  ██╗ ██╗   ██╗ ",
			"  ██╔══██╗ ██╔══██╗ ██╔════╝ ██║  ██║ ╚██╗ ██╔╝ ",
			"  ██║  ██║ ███████║ ███████╗ ███████║  ╚████╔╝  ",
			"  ██║  ██║ ██╔══██║ ╚════██║ ██╔══██║   ╚██╔╝   ",
			"  ██████╔╝ ██║  ██║ ███████║ ██║  ██║    ██║    ",
			"  ╚═════╝  ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝    ╚═╝    ",
		},
		center = {
			"",
			"  󰮗 Find File",
			"  󰬵 Live Grep",
			"  󰷏 Recent Files",
			-- "  [󰚰] Projects", uncomment if using project.nvim, and want to add this menu
			-- entry
			"  󰖟 Config",
			"  󰒲 Lazy",
			"  󰈆 Quit",
			"",
		},
		footer = {
			"",
			"  Neovim Dashboard",
			"  Press 'q' to close",
			"",
		},
	}

	return content
end

-- Apply highlights to the dashboard
---@param buf_id number Buffer ID
---@param highlights table The highlights to apply
function M.apply_highlights(buf_id, highlights)
	-- Define highlight groups
	local highlight_groups = {
		-- Header
		{ group = "DashboardHeader", line = 1, col_start = 1, col_end = 80 },
		{ group = "DashboardHeader", line = 2, col_start = 1, col_end = 80 },
		{ group = "DashboardHeader", line = 3, col_start = 1, col_end = 80 },
		{ group = "DashboardHeader", line = 4, col_start = 1, col_end = 80 },
		{ group = "DashboardHeader", line = 5, col_start = 1, col_end = 80 },
		{ group = "DashboardHeader", line = 6, col_start = 1, col_end = 80 },

		-- Footer
		{ group = "DashboardFooter", line = #highlights - 3, col_start = 1, col_end = 20 },
		{ group = "DashboardFooter", line = #highlights - 2, col_start = 1, col_end = 20 },
		{ group = "DashboardFooter", line = #highlights - 1, col_start = 1, col_end = 20 },
	}

	-- Apply highlights
	local ns_id = vim.api.nvim_create_namespace("dashy_theme")
	for _, hl in ipairs(highlight_groups) do
		vim.api.nvim_buf_add_highlight(buf_id, ns_id, hl.group, hl.line - 1, hl.col_start - 1, hl.col_end - 1)
	end
end

return M
