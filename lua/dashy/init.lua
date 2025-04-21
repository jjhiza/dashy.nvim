---@mod dashy A modern dashboard for Neovim
---@author Mini Jay
---@license MIT

-- Check for Neovim version compatibility
if vim.fn.has("nvim-0.10.0") == 0 then
  vim.api.nvim_err_writeln("Dashy requires at least Neovim 0.10.0")
  return
end

-- Define Dashy namespace
local ns = vim.api.nvim_create_namespace("dashy")

---@class Dashy
---@field private ns number The namespace ID for Dashy
---@field private initialized boolean Whether Dashy has been initialized
---@field private config table Configuration options
local Dashy = {
  ns = ns,
  initialized = false,
}

-- Safe requiring of modules with error handling
---@param module string The module to require
---@return any|nil The loaded module or nil if there was an error
Dashy.safe_require = function(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify(
      string.format("Dashy error loading %s: %s", module, result),
      vim.log.levels.ERROR
    )
    return nil
  end
  return result
end

---@class DashySetupOptions
---@field theme? string Theme name to use
---@field hide? {statusline?: boolean, tabline?: boolean, winbar?: boolean} UI elements to hide
---@field autoopen? boolean Whether to automatically open Dashy on startup
---@field shortcut_type? "letter"|"number" Type of shortcuts to display
---@field shortcut_style? "icon"|"text" Style of shortcuts to display
---@field sections? {header?: table, center?: table, footer?: table} Dashboard sections configuration
---@field features? {sessions?: table, project_history?: table, recent_files?: table, shortcuts?: table} Feature configurations

-- Default configuration options
---@type DashySetupOptions
Dashy._DEFAULT_CONFIG = {
  theme = "rose-pine-moon",
  hide = {
    statusline = true,
    tabline = true,
    winbar = true,
  },
  autoopen = true,
  shortcut_type = "letter",
  shortcut_style = "icon",
  sections = {
    header = {},
    center = {},
    footer = {},
  },
  features = {
    sessions = {
      enabled = true,
      max_entries = 10,
      save_on_exit = true,
      display_type = "list",
    },
    project_history = {
      enabled = true,
      max_entries = 10,
      track_git_branches = true,
      save_project_stats = true,
      display_type = "grid",
    },
    recent_files = {
      enabled = true,
      max_entries = 10,
      exclude_filetypes = {"gitcommit", "gitrebase", "help", "qf"},
      exclude_buftype = {"terminal", "quickfix", "nofile", "help"},
      save_write_times = true,
      display_type = "list",
      show_icons = true,
    },
    shortcuts = {
      enabled = true,
      display_type = "grid",
      show_icons = true,
      show_labels = true,
      shortcut_style = "letter",
    },
  },
}

-- Setup function to initialize Dashy with user configuration
---@param opts? DashySetupOptions User configuration options
---@return Dashy The Dashy instance
function Dashy.setup(opts)
  -- Ensure setup is only called once
  if Dashy.initialized then
    vim.notify("Dashy is already initialized", vim.log.levels.WARN)
    return Dashy
  end

  -- Load and merge configurations
  Dashy.config = vim.tbl_deep_extend("force", Dashy._DEFAULT_CONFIG, opts or {})

  -- Load required modules
  local config = Dashy.safe_require("dashy.config")
  if not config then
    return Dashy
  end

  -- Initialize configuration
  config.init(Dashy.config)
  
  -- Initialize features
  local features = Dashy.safe_require("dashy.features")
  if features then
    features.init(Dashy.config)
  end

  -- Define autocmd group for Dashy
  local augroup = vim.api.nvim_create_augroup("Dashy", { clear = true })

  -- Setup auto-open if configured
  if Dashy.config.autoopen then
    vim.api.nvim_create_autocmd("VimEnter", {
      group = augroup,
      callback = function()
        -- Only open on empty buffer in normal mode
        if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 and vim.fn.mode() == "n" then
          vim.schedule(function()
            Dashy.open()
          end)
        end
      end,
      desc = "Auto-open Dashy on startup",
    })
  end

  -- Handle UI resize
  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
      -- Check if Dashy is currently visible and redraw it
      local layout = Dashy.safe_require("dashy.layout")
      if layout and layout.is_visible() then
        vim.schedule(function()
          layout.redraw()
        end)
      end
    end,
    desc = "Redraw Dashy on resize",
  })

  Dashy.initialized = true
  return Dashy
end

-- Open the Dashy dashboard
---@return boolean success Whether opening was successful
function Dashy.open()
  -- Ensure Dashy is initialized
  if not Dashy.initialized then
    vim.notify("Please call Dashy.setup() before opening", vim.log.levels.ERROR)
    return false
  end

  -- Load required modules for opening
  local layout = Dashy.safe_require("dashy.layout")
  if not layout then
    return false
  end

  -- Attempt to create and show the dashboard
  local success, err = pcall(function()
    layout.create()
  end)

  if not success then
    vim.notify("Failed to open Dashy: " .. err, vim.log.levels.ERROR)
    return false
  end

  return true
end

-- Close the Dashy dashboard
---@return boolean success Whether closing was successful
function Dashy.close()
  local layout = Dashy.safe_require("dashy.layout")
  if not layout then
    return false
  end

  local success, err = pcall(function()
    layout.destroy()
  end)

  if not success then
    vim.notify("Failed to close Dashy: " .. err, vim.log.levels.ERROR)
    return false
  end

  return true
end

-- Register commands
vim.api.nvim_create_user_command("Dashy", function(opts)
  if not Dashy.initialized then
    vim.notify("Please call Dashy.setup() before using the command", vim.log.levels.ERROR)
    return
  end
  
  if opts.args == "open" or opts.args == "" then
    Dashy.open()
  elseif opts.args == "close" then
    Dashy.close()
  else
    vim.notify("Invalid Dashy command. Use :Dashy open or :Dashy close", vim.log.levels.ERROR)
  end
end, {
  nargs = "?",
  complete = function(_, line)
    local l = vim.split(line, "%s+")
    if #l == 1 then
      return {"open", "close"}
    end
    return {}
  end,
  desc = "Open or close the Dashy dashboard"
})

-- Return the Dashy module
return Dashy

