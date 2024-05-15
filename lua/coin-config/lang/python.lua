local lspconfig = require("lspconfig")
local tools = require("coin-config.tools")

-- 配置 Python LSP (Pyright)
lspconfig.pyright.setup({
  before_init = function(params)
    local conda_venv_path, conda_python_path = tools.get_conda_path()
    if conda_venv_path then
      params.settings.python.venvPath = conda_venv_path
      params.settings.python.pythonPath = conda_python_path
    end
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
  filetypes = { "python" },
})
