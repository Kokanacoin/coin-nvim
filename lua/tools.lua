local M = {}

function M.get_conda_path()
  local handle = io.popen("conda info --json")
  local result = handle:read("*a")
  handle:close()

  if not result or result == "" then
    print("Error: Unable to retrieve Conda info")
    return nil, nil
  end

  local conda_info = vim.fn.json_decode(result)

  if not conda_info or not conda_info['default_prefix'] then
    print("Error: Unable to decode Conda info JSON")
    return nil, nil
  end

  local conda_path = conda_info['default_prefix']
  local python_path = conda_path .. "/bin/python"

  -- Handle Windows case
  if package.config:sub(1,1) == '\\' then
    python_path = conda_path .. "\\python.exe"
  end

  return conda_path, python_path
end

-- 自动加载配置文件
function M.load_configs(base_path, configs)
  for name, enabled in pairs(configs) do
    if enabled then
      local config_path = string.format("%s.%s", base_path, name)
      local ok, err = pcall(require, config_path)
      if not ok then
        print(string.format("Failed to load config: %s\nError: %s", config_path, err))
      end
    end
  end
end

return M
