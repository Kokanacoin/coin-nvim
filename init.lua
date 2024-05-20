-- 初始化 lazy.nvim 配置
require("config.lazy")

-------------------------------------------------------------------------------
-- 全局设置
vim.opt.relativenumber = false -- 关闭相对行号
vim.opt.tabstop = 4 -- 设置 tab 的显示宽度为 4 个字符
vim.opt.shiftwidth = 4 -- 设置缩进宽度为 4 个空格
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 一些开关，用来控制是否启动一些插件的
local lsp = {

  -- Golang LSP (gopls) 安装命令：
  --          go install golang.org/x/tools/gopls@latest
  go = false,

  -- Vue LSP (volar) 安装命令：
  --          npm install -g @vue/language-server
  --          npm install -g @vue/typescript-plugin
  vue = false,

  -- Python LSP (Pyright) 安装命令：
  --          npm install -g pyright
  python = false,
}
-- 插件开关变量dc
local plugin = {
  dap = false,
}
-------------------------------------------------------------------------------

-- 引入通用函数
local tools = require("coin-config.tools")

-- 引入 LSP 配置
vim.lsp.set_log_level("debug")
tools.load_configs("coin-config/lang", lsp)

-- 引入插件配置
tools.load_configs("coin-config/plugin", plugin)
