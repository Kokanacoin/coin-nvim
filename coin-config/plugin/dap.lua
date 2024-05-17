local dap = require("dap")
local tools = require("coin-config.tools")

-- 获取 Conda 的默认环境路径和 Python 解释器路径
local conda_path, python_path = tools.get_conda_path()


-- 设置 DAP 的适配器
dap.adapters.python = {
  type = "executable",
  command = python_path, -- 使用 Conda 环境中的 Python
  args = { "-m", "debugpy.adapter" },
}

-- 配置 Python 调试
dap.configurations.python = {
  {
    name = "Launch",
    type = "python",
    request = "launch",
    program = "${file}",
    pythonPath = function()
      -- 动态获取当前环境的 Python 解释器路径
      local conda_path, python_path = tools.get_conda_path()
      if conda_path and python_path then
        print("Dynamic Conda Path: " .. conda_path)
        print("Dynamic Python Path: " .. python_path)
        return python_path
      else
        print("Error: Unable to dynamically determine Conda or Python paths.")
        return nil
      end
    end,
  },
}
