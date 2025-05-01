return {
  "nvimdev/dashy.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local function create_python_project()
      local project_name = vim.fn.input("Project name: ")
      local python_version = vim.fn.input("Python version (default: 3.11): ") or "3.11"
      local venv_name = vim.fn.input("Virtual environment name (default: venv): ") or "venv"
      
      local commands = {
        string.format("new-proj %s", project_name),
        string.format("cd ~/Projects/%s", project_name),
        string.format("py-env %s %s", python_version, venv_name),
        "source venv/bin/activate",
        "touch main.py requirements.txt README.md .gitignore",
        "git init"
      }
      
      for _, cmd in ipairs(commands) do
        local success = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
          vim.notify("Error executing command: " .. cmd, vim.log.levels.ERROR)
          return
        end
      end
      
      vim.cmd("edit main.py")
    end

    require("dashy").setup({
      theme = "rose-pine-moon",
      sections = {
        center = {
          menu = {
            {
              icon = "",
              icon_hl = "DashboardIcon",
              desc = "New Python Project",
              desc_hl = "DashboardDesc",
              action = function()
                create_python_project()
                vim.cmd("q")
              end
            },
            {
              icon = "",
              icon_hl = "DashboardIcon",
              desc = "Find File",
              desc_hl = "DashboardDesc",
              action = "Telescope find_files"
            },
            {
              icon = "",
              icon_hl = "DashboardIcon",
              desc = "Quit",
              desc_hl = "DashboardDesc",
              action = "qa"
            }
          }
        }
      }
    })
  end
} 