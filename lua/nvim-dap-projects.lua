local M = {}

M.config_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }

function M.search_project_config()
  if not pcall(require, "dap") then
    vim.notify("[nvim-dap-projects] Could not find nvim-dap, make sure you load it before nvim-dap-projects.",
      vim.log.levels.ERROR, nil)
    return
  end
  local project_config = ""
  for _, p in ipairs(M.config_paths) do
    local f = io.open(p)
    if f ~= nil then
      f:close()
      project_config = p
      break
    end
  end
  if project_config == "" then
    return
  end
  vim.notify("[nvim-dap-projects] Found nvim-dap configuration at." .. project_config, vim.log.levels.INFO, nil)
  local local_config = dofile(project_config)
  if local_config == nil then
    return
  else
    if local_config.adapters ~= nil then
      local adapters = vim.tbl_deep_extend('force', require 'dap'.adapters, local_config.adapters)
      require 'dap'.adapters = adapters
    end
    if local_config.configurations ~= nil then
      local local_configurations = local_config.configurations
      local global_configurations = require 'dap'.configurations
      for key, local_list in pairs(local_configurations) do
        local global_list = global_configurations[key]
        if global_list ~= nil then
          vim.list_extend(local_list, global_list)
        end
        local_configurations[key] = local_list
      end
      local_configurations = vim.tbl_deep_extend('keep', local_configurations, global_configurations)
      require 'dap'.configurations = local_configurations
    end
  end
end

--[[
example config:

return {
  configurations = {
    rust = {
      {
        name = 'Debug my rust program',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.getcwd() .. './target/debug/foo.exe'
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {}
      }
    }
  }
}
]]

return M
