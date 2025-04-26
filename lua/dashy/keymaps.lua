---@mod dashy.keymaps Keymap management for Dashy
---@brief [[
-- Provides keymap configuration and management for the Dashy dashboard.
-- Handles default keybindings, user-configurable mappings, and shortcut display.
-- ]]

-- Module definition
---@class DashyKeymaps
local M = {}

-- Store local references to Vim APIs for performance
local api = vim.api
local keymap = vim.keymap

-- Get safe require from main module
local dashy = require("dashy")
local safe_require = dashy.safe_require

-- Store active keymaps to allow for cleanup
---@type table<number, string[]>
local active_mappings = {}

-- Define keymap action types
---@alias DashyKeymapAction
---| "quit" # Close the dashboard
---| "open_file" # Open a file
---| "find_files" # Find files
---| "find_recent" # Find recent files
---| "new_file" # Create a new file
---| "find_projects" # Find projects
---| "load_session" # Load a session
---| "browse_dotfiles" # Browse dotfiles
---| "check_health" # Run health check
---| "update_plugins" # Update plugins
---| "settings" # Open settings
---| "help" # Open help
---| "custom" # Custom action

-- Define keymap shortcut display types
---@alias DashyShortcutType
---| "letter" # Letter-based shortcuts (a, b, c, ...)
---| "number" # Number-based shortcuts (1, 2, 3, ...)

-- Define keymap shortcut display styles
---@alias DashyShortcutStyle
---| "icon" # Icon-based shortcuts
---| "text" # Text-based shortcuts

---@class DashyKeymapDefinition
---@field key string The key to map
---@field action DashyKeymapAction The action to perform
---@field desc string Description of the mapping
---@field label string|nil Label to display in shortcut (defaults to key)
---@field shortcut_type DashyShortcutType|nil Type of shortcut (letter or number)
---@field shortcut_style DashyShortcutStyle|nil Style of shortcut (icon or text)
---@field shortcut_icon string|nil Icon to display for the shortcut (if using icon style)
---@field callback function|nil Custom callback function for the action
---@field opts table|nil Additional options for the keymap

-- Action handlers
local actions = {
    -- Open a new file
    new_file = function()
        vim.cmd("enew")
    end,

    -- Find files using Telescope
    find_files = function()
        if vim.fn.exists(":Telescope") == 2 then
            vim.cmd("Telescope find_files")
        else
            vim.notify("Telescope is not installed", vim.log.levels.WARN)
        end
    end,

    -- Find recent files using Telescope
    recent_files = function()
        if vim.fn.exists(":Telescope") == 2 then
            vim.cmd("Telescope oldfiles")
        else
            vim.notify("Telescope is not installed", vim.log.levels.WARN)
        end
    end,

    -- Find projects using project.nvim
    find_projects = function()
        if vim.fn.exists(":Telescope") == 2 and vim.fn.exists(":ProjectRoot") == 2 then
            vim.cmd("Telescope project")
        else
            vim.notify("Telescope and project.nvim are required", vim.log.levels.WARN)
        end
    end,

    -- Load session using persistence.nvim
    load_session = function()
        if vim.fn.exists(":SessionLoad") == 2 then
            vim.cmd("SessionLoad")
        else
            vim.notify("persistence.nvim is not installed", vim.log.levels.WARN)
        end
    end,

    -- Update plugins using lazy.nvim
    update_plugins = function()
        if vim.fn.exists(":Lazy") == 2 then
            vim.cmd("Lazy update")
        else
            vim.notify("lazy.nvim is not installed", vim.log.levels.WARN)
        end
    end,

    -- Open help documentation
    help = function()
        vim.cmd("help dashy")
    end,

    -- Run health check
    health = function()
        vim.cmd("checkhealth")
    end,

    -- Quit dashboard
    quit = function()
        -- Get the Dashy module to properly close the dashboard
        local dashy = require("dashy")
        dashy.close()
    end,

    -- Execute the currently selected action
    execute_selection = function()
        local current_line = vim.api.nvim_get_current_line()
        local theme_module = safe_require("dashy.theme.default")
        
        if not theme_module or not theme_module.get_menu_items then
            vim.notify("Could not load menu items", vim.log.levels.ERROR)
            return
        end
        
        local menu_items = theme_module.get_menu_items()
        local current_buf = vim.api.nvim_get_current_buf()
        
        -- Helper function to execute an action
        local function execute_item_action(action)
            -- Special handling for bdelete to close Dashy properly
            if action == "bdelete" then
                -- Use the close method from Dashy to ensure proper cleanup
                local dashy = require("dashy")
                dashy.close()
            else
                -- Execute other commands normally
                vim.cmd(action)
            end
        end
        
        -- Check for menu items in the current line
        for _, item in ipairs(menu_items) do
            -- Try to match any part of the description in the line
            if current_line:match(item.desc) then
                execute_item_action(item.action)
                return
            end
        end
        
        vim.notify("No action found for the selected item", vim.log.levels.WARN)
    end,
}

-- Default keymaps
local default_keymaps = {
    {
        key = "<CR>",
        action = "execute_selection",
        desc = "Execute selection",
        label = "<CR>",
    },
}

-- Optional keymaps that can be enabled via config
local optional_keymaps = {}

-- Number-based default keymaps alternative
---@type DashyKeymapDefinition[]
local number_keymaps = {
    {
        key = "<CR>",
        action = "execute_selection",
        desc = "Execute selection",
        label = "<CR>",
    },
}

-- Optional number-based keymaps
local optional_number_keymaps = {}

-- Create a keymap for a specific buffer
---@param buf_id number Buffer ID to map keys in
---@param key string Key to map
---@param action DashyKeymapAction Action to perform
---@param desc string Description for the mapping
---@param callback function|nil Custom callback function
---@param opts table|nil Additional options
local function create_buffer_keymap(buf_id, key, action, desc, callback, opts)
    opts = vim.tbl_extend("force", { silent = true, noremap = true, nowait = true, desc = desc }, opts or {})

    -- Register the mapping
    keymap.set("n", key, function()
        execute_action(action, callback)
    end, vim.tbl_extend("force", opts, { buffer = buf_id }))

    -- Store for cleanup
    if not active_mappings[buf_id] then
        active_mappings[buf_id] = {}
    end
    table.insert(active_mappings[buf_id], key)
end

-- Get keymap definitions based on configuration
---@return DashyKeymapDefinition[]
local function get_keymap_definitions()
    local config = safe_require("dashy.config")
    if not config then
        return default_keymaps
    end

    -- Check shortcut type configuration
    local shortcut_type = config.get("shortcut_type") or "letter"
    local keymaps = shortcut_type == "number" and number_keymaps or default_keymaps

    -- Check if projects feature is enabled
    local features = config.get("features") or {}
    local project_history = features.project_history or {}
    if project_history.enabled then
        -- Add optional keymaps if the feature is enabled
        local optional = shortcut_type == "number" and optional_number_keymaps or optional_keymaps
        for _, keymap in ipairs(optional) do
            table.insert(keymaps, keymap)
        end
    end

    return keymaps
end

-- Get user-defined keymaps from configuration
---@return DashyKeymapDefinition[]
local function get_user_keymaps()
    local config = safe_require("dashy.config")
    if not config then
        return {}
    end

    local user_keymaps = config.get("keymaps") or {}
    return user_keymaps
end

-- Merge default keymaps with user-defined keymaps
---@return DashyKeymapDefinition[]
local function merge_keymaps()
    local keymaps = get_keymap_definitions()
    local user_keymaps = get_user_keymaps()

    -- Create a map of default keymaps by key for easy lookup
    local keymaps_by_key = {}
    for _, keymap in ipairs(keymaps) do
        keymaps_by_key[keymap.key] = true
    end

    -- Add user keymaps that don't override defaults
    for _, user_keymap in ipairs(user_keymaps) do
        -- If key already exists, replace the default mapping
        local existing_idx = nil
        for idx, keymap in ipairs(keymaps) do
            if keymap.key == user_keymap.key then
                existing_idx = idx
                break
            end
        end

        if existing_idx then
            keymaps[existing_idx] = user_keymap
        else
            table.insert(keymaps, user_keymap)
        end
    end

    return keymaps
end

-- Setup keymaps for the dashboard
---@param bufnr number Buffer ID
function M.setup_dashboard_keymaps(bufnr)
    -- Set up Enter key to execute selection
    vim.keymap.set("n", "<CR>", function()
        actions.execute_selection()
    end, {
        buffer = bufnr,
        silent = true,
        noremap = true,
        desc = "Execute selection",
    })

    -- Set up 'q' to close the dashboard using the quit action
    vim.keymap.set("n", "q", function()
        actions.quit()
    end, {
        buffer = bufnr,
        silent = true,
        noremap = true,
        desc = "Close Dashy",
    })

    -- Position cursor on the first menu item
    vim.schedule(function()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        -- Find the first line after the header that contains a menu item
        for i, line in ipairs(lines) do
            if line:match("%[") and line:match("Find File") then
                -- Find the position of the "F" in "Find File"
                local col = line:find("F")
                if col then
                    vim.api.nvim_win_set_cursor(0, { i, col - 1 })
                    break
                end
            end
        end
    end)
    
    -- Add basic menu navigation with highlight updates
    vim.keymap.set("n", "j", function()
        -- Move down one row
        local cursor = vim.api.nvim_win_get_cursor(0)
        local current_line = vim.api.nvim_get_current_line()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local next_line = lines[cursor[1] + 1]
        
        -- Check if next line has menu items (contains brackets)
        if next_line and next_line:match("%[") then
            vim.api.nvim_win_set_cursor(0, {cursor[1] + 1, cursor[2]})
        end
    end, {
        buffer = bufnr,
        silent = true,
        noremap = true,
        desc = "Move selection down",
    })
    
    vim.keymap.set("n", "k", function()
        -- Move up one row
        local cursor = vim.api.nvim_win_get_cursor(0)
        local current_line = vim.api.nvim_get_current_line()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local prev_line = lines[cursor[1] - 1]
        
        -- Check if prev line has menu items (contains brackets)
        if prev_line and prev_line:match("%[") then
            vim.api.nvim_win_set_cursor(0, {cursor[1] - 1, cursor[2]})
        end
    end, {
        buffer = bufnr,
        silent = true,
        noremap = true,
        desc = "Move selection up",
    })
end

-- Setup window-specific keymaps
---@param win_id number Window ID
function M.setup_dashboard_win_keymaps(win_id)
    -- Set window-local options
    vim.api.nvim_win_set_option(win_id, "number", false)
    vim.api.nvim_win_set_option(win_id, "relativenumber", false)
    vim.api.nvim_win_set_option(win_id, "cursorline", true)  -- Enable cursorline for highlighting
    vim.api.nvim_win_set_option(win_id, "cursorcolumn", false)
    vim.api.nvim_win_set_option(win_id, "foldcolumn", "0")
    vim.api.nvim_win_set_option(win_id, "signcolumn", "no")
    vim.api.nvim_win_set_option(win_id, "colorcolumn", "")
    
    -- Create a namespace for dashboard-specific highlights
    local ns_id = vim.api.nvim_create_namespace("dashy_highlights")
    
    -- Apply the namespace to the window
    vim.api.nvim_win_set_hl_ns(win_id, ns_id)
    
    -- Set CursorLine highlight in the namespace to use DashboardCenterCursor
    vim.api.nvim_set_hl(ns_id, "CursorLine", { link = "DashboardCenterCursor" })
end

-- Execute a keymap action
---@param action DashyKeymapAction The action to execute
---@param callback function|nil Custom callback for custom actions
local function execute_action(action, callback)
    if actions[action] then
        if action == "custom" then
            actions[action](callback)
        else
            actions[action]()
        end
    else
        vim.notify("Unknown action: " .. action, vim.log.levels.ERROR)
    end
end

-- Return the module
return M
