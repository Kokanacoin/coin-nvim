-- 初始化 lazy.nvim 配置
require("config.lazy")

-- 全局设置
vim.opt.relativenumber = false -- 关闭相对行号
vim.opt.tabstop = 4 -- 设置 tab 的显示宽度为 4 个字符
vim.opt.shiftwidth = 4 -- 设置缩进宽度为 4 个空格

-- 语言LSP支持
-- =====================================================================================================
-- 引入 LSP 相关模块
local lspconfig = require("lspconfig")

-- Python
-- Python LSP 配置 (Pyright)
-- 安装命令：npm install -g pyright
-- -----------------------------------------------------------------------------------------------------
-- 获取 Conda 环境路径
local function get_conda_path()
  local handle = io.popen("conda info --json")
  local result = handle:read("*a")
  handle:close()
  local path = result:match('"default_prefix": "(.-)"'):gsub("/", "\\")
  return path, path .. "\\python"
end

-- 配置 Python LSP (Pyright)
lspconfig.pyright.setup({
  before_init = function(params)
    local conda_venv_path, conda_python_path = get_conda_path()
    if conda_venv_path then
      params.settings.python.venvPath = conda_venv_path
      params.settings.python.pythonPath = conda_python_path
    end
  end,
  settings = {
    python = {
      analysis = { autoSearchPaths = true, useLibraryCodeForTypes = true },
    },
  },
})

-- Golang LSP 配置 (gopls)
-- 安装命令：go install golang.org/x/tools/gopls@latest
-- -----------------------------------------------------------------------------------------------------
lspconfig.gopls.setup({
  on_attach = function(_, bufnr)
    local function buf_set_keymap(mode, lhs, rhs, opts)
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    local function buf_set_option(option, value)
      vim.api.nvim_buf_set_option(bufnr, option, value)
    end

    -- 设置当前缓冲区的特定按键映射 (例如, 在 Golang 中使用 'K' 显示文档)
    buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
  end,
})