# 🪙中文Lazy Nvim 使用教程

这是一个中文版的`lazy.nvim`的使用教程，包含安装、配置、踩坑记录等。

还包含汉语版各个插件的快捷键文档，更适合中国体质的宝宝。

目前语言支持有(后续会添加)：

- [x] Python
- [x] Golang
- [x] Vue
- [ ] Java

## Ⅰ 安装

### Neovim安装

**Neovim** 是一个基于 Vim 的文本编辑器，旨在改进 Vim 并添加新功能，同时保持与 Vim 的兼容性。Neovim 试图简化 Vim 的代码基础，使得开发和维护更加容易，并且支持现代功能，如异步 I/O、插件运行时和改进的脚本语言支持。

**Windows**

- 通过**Winget**安装

```shell
winget install Neovim.Neovim
```

- 通过**Chocolatey**安装

```shell
choco install neovim --pre
```

**MacOS or Linux**

```shell
brew install neovim
```

### lazy.nvim安装

为了能够简化`Neovim`插件的配置，这里推荐安装`lazy.nvim`。

**Windows**

- 将当前的`nvim`配置文件进行备份

```SHELL
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak
# optional but recommended
Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak
```

- 复制仓库

```shell
git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim
Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force
```

虽然`lazy.nvim`已经为我们提供了很多便捷的操作，但还是要自己配置。下面是我自己做的仓库，里面添加了一些对`lazy.nvim`的修改，其中包括一些特定语言的语法支持。

```shell
git clone https://github.com/Kokanacoin/coin-nvim $env:LOCALAPPDATA\nvim
```

## Ⅱ 配置

这里需要下载一个终端来运行`nvim`，原生的终端是可以，不过有些显示会出现问题。这里官方推荐了一些，我直接引用过来，我在使用的是`Wezterm`
>- [kitty](https://github.com/kovidgoyal/kitty) ***(Linux & Macos)\***
>- [wezterm](https://github.com/wez/wezterm) ***(Linux, Macos & Windows)\***
>- [alacritty](https://github.com/alacritty/alacritty) ***(Linux, Macos & Windows)\***
>- [iterm2](https://iterm2.com/) ***(Macos)\***

所有的`nvim`的配置文件都在安装目录下的`init.lua`脚本中配置。

另外有时候可能需要配置一下终端的显示，比如让`nvim`能够**全屏显示**，**字体大小**等等，有需要可以自行配置。

下面是`wezterm`的配置文件的路径

- **Windows**: `C:\Users\<你的用户名>\.wezterm.lua`
- **macOS 和 Linux**: `/home/<你的用户名>/.wezterm.lua` 或者 `~/.wezterm.lua`

```lua
local wezterm = require 'wezterm';

return {
  -- 字体设置
  font = wezterm.font("JetBrains Mono"),
  font_size = 12.0,

  -- 窗口内边距和边框高度设置为0，去除边框
  window_padding = {left = 0, right = 0, top = 0, bottom = 0},
  window_frame = {
    border_left_width = 0,
    border_right_width = 0,
    border_bottom_height = 0,
    border_top_height = 0,
    -- 边框颜色设置
    border_top_color = "black",
    border_bottom_color = "black",
    border_left_color = "black",
    border_right_color = "black",
  },

  -- 其他窗口设置
  enable_wayland = false,  -- 在使用 Wayland 时设置为 true
  use_fancy_tab_bar = false,
}
```

## Ⅲ 语言支持

### Golang

- 安装`gopl`

```shell
go install golang.org/x/tools/gopls@latest
```

- 在`init.lua`配置：

```lua
local lspconfig = require("lspconfig")

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
```

- 可以在`nvim`中安装支持go语言的语法高亮

```
:TSInstall go
```

### Python

- 安装`pyright`

```SHELL	
npm install -g pyright
```

- `init.lua`中配置：

```lua
local lspconfig = require("lspconfig")

local function get_conda_path()
  local handle = io.popen("conda info --json")
  local result = handle:read("*a")
  handle:close()
  local path = result:match('"default_prefix": "(.-)"')
  if path then
    path = path:gsub("/", "\\")
    return path, path .. "\\python"
  end
end

lspconfig.pyright.setup({
  before_init = function(params)
    local conda_venv_path, conda_python_path = get_conda_path()
    if conda_venv_path and conda_python_path then
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
})
```

### Vue

这里通过非混合模式来配置`Vue`的`lsp`。

- 首先通过`npm`安装一些环境

```shell
npm install -g @vue/language-server
npm install -g @vue/typescript-plugin 
```

- 在`init.lua`配置

```lua
lspconfig.volar.setup {
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    init_options = {
        vue = {
            hybridMode = false,
        },
    },
}
```







## Ⅳ 一些坑

### Windows环境下nvim-treesitter，找不到so文件

这个问题的原因是有一些插件需要在`linux`运行，他们会自动找`so`文件，但是`windows`上只有`dll`。最简单解决办法就是换一个`gcc`就可以了。

下载并且安装这个[MinGW](https://winlibs.com/)

### Pyright与volar冲突

在同时安装`pyright`(py支持)与`volar`(vue支持)的时候，会发生一些冲突，导致自动审核代码插件在`ts`脚本发生错误。解决办法是对每种语言的`lsp`限制`filetype`,让一些文件仅仅使用自己的语言的插件。

不过经测试，`pyright`的代码检测能力也可以应用在go上，在别的地方用不了是真的遗憾，有问题可以联系我。

## 附录：中文键位对应表

- 默认的`<leader>` 是 `<space>`
- 默认的`<localleader>` 是 `\`

### 通用

| 键位                 | 描述                       | 模式       |
| -------------------- | -------------------------- | ---------- |
| `<C-h>`              | 跳至左侧窗口               | n, t       |
| `<C-j>`              | 跳至下方窗口               | n, t       |
| `<C-k>`              | 跳至上方窗口               | n, t       |
| `<C-l>`              | 跳至右侧窗口               | n, t       |
| `<C-Up>`             | 增加窗口高度               | n          |
| `<C-Down>`           | 减少窗口高度               | n          |
| `<C-Left>`           | 减少窗口宽度               | n          |
| `<C-Right>`          | 增加窗口宽度               | n          |
| `<A-j>`              | 向下移动                   | n, i, v    |
| `<A-k>`              | 向上移动                   | n, i, v    |
| `<S-h>`              | 切换至上一个缓冲区         | n          |
| `<S-l>`              | 切换至下一个缓冲区         | n          |
| `[b`                 | 切换至上一个缓冲区         | n          |
| `]b`                 | 切换至下一个缓冲区         | n          |
| `<leader>bb`         | 切换至其他缓冲区           | n          |
| `<leader>\``         | 切换至其他缓冲区           | n          |
| `<esc>`              | 退出并清除搜索高亮         | i, n       |
| `<leader>ur`         | 重绘/清除搜索高亮/更新差异 | n          |
| `n`                  | 下一个搜索结果             | n, x, o    |
| `N`                  | 上一个搜索结果             | n, x, o    |
| `<C-s>`              | 保存文件                   | i, x, n, s |
| `<leader>K`          | Keywordprg                 | n          |
| `<leader>l`          | Lazy                       | n          |
| `<leader>fn`         | 新建文件                   | n          |
| `<leader>xl`         | 位置列表                   | n          |
| `<leader>xq`         | 问题列表                   | n          |
| `[q`                 | 上一个问题                 | n          |
| `]q`                 | 下一个问题                 | n          |
| `<leader>cf`         | 格式化                     | n, v       |
| `<leader>cd`         | 行诊断                     | n          |
| `]d`                 | 下一个诊断                 | n          |
| `[d`                 | 上一个诊断                 | n          |
| `]e`                 | 下一个错误                 | n          |
| `[e`                 | 上一个错误                 | n          |
| `]w`                 | 下一个警告                 | n          |
| `[w`                 | 上一个警告                 | n          |
| `<leader>uf`         | 切换自动格式化 (全局)      | n          |
| `<leader>uF`         | 切换自动格式化 (缓冲区)    | n          |
| `<leader>us`         | 切换拼写检查               | n          |
| `<leader>uw`         | 切换自动换行               | n          |
| `<leader>uL`         | 切换相对行号               | n          |
| `<leader>ul`         | 切换行号显示               | n          |
| `<leader>ud`         | 切换诊断信息               | n          |
| `<leader>uc`         | 切换隐藏字符显示           | n          |
| `<leader>uh`         | 切换嵌入提示               | n          |
| `<leader>uT`         | 切换 Treesitter 高亮       | n          |
| `<leader>ub`         | 切换背景颜色               | n          |
| `<leader>gg`         | Lazygit (根目录)           | n          |
| `<leader>gG`         | Lazygit (当前工作目录)     | n          |
| `<leader>gb`         | Git 责备当前行             | n          |
| `<leader>gf`         | Lazygit 当前文件历史       | n          |
| `<leader>qq`         | 退出所有                   | n          |
| `<leader>ui`         | 检查位置信息               | n          |
| `<leader>L`          | LazyVim 更新日志           | n          |
| `<leader>ft`         | 终端 (根目录)              | n          |
| `<leader>fT`         | 终端 (当前工作目录)        | n          |
| `<c-/>`              | 终端 (根目录)              | n          |
| `<c-_>`              | 忽略 which_key             | n, t       |
| `<esc><esc>`         | 进入普通模式               | t          |
| `<C-/>`              | 隐藏终端                   | t          |
| `<leader>ww`         | 切换至其他窗口             | n          |
| `<leader>wd`         | 关闭窗口                   | n          |
| `<leader>w-`         | 下方分割窗口               | n          |
| `<leader>w|`         | 右侧分割窗口               | n          |
| `<leader>-`          | 下方分割窗口               | n          |
| `<leader>|`          | 右侧分割窗口               | n          |
| `<leader><tab>l`     | 最后一个标签页             | n          |
| `<leader><tab>f`     | 第一个标签页               | n          |
| `<leader><tab><tab>` | 新建标签页                 | n          |
| `<leader><tab>]`     | 下一个标签页               | n          |
| `<leader><tab>d`     | 关闭标签页                 | n          |
| `<leader><tab>[`     | 上一个标签页               | n          |

### LSP

| 键位         | 描述                | 模式 |
| ------------ | ------------------- | ---- |
| `<leader>cl` | LSP 信息            | n    |
| `gd`         | 跳转到定义          | n    |
| `gr`         | 引用                | n    |
| `gD`         | 跳转到声明          | n    |
| `gI`         | 跳转到实现          | n    |
| `gy`         | 跳转到类型定义      | n    |
| `K`          | 悬停                | n    |
| `gK`         | 签名帮助            | n    |
| `<c-k>`      | 签名帮助            | i    |
| `<leader>ca` | 代码操作            | n, v |
| `<leader>cc` | 运行 Codelens       | n, v |
| `<leader>cC` | 刷新并显示 Codelens | n    |
| `<leader>cA` | 来源操作            | n    |
| `<leader>cr` | 重命名              | n    |

### [bufferline.nvim](https://github.com/akinsho/bufferline.nvim.git)

这些键位用于管理 NeoVim 中的缓冲区，允许您有效地关闭或切换不同的文件缓冲区。

| 键位         | 描述               | 模式 |
| ------------ | ------------------ | ---- |
| `<leader>bl` | 删除左侧缓冲区     | n    |
| `<leader>bo` | 删除其他缓冲区     | n    |
| `<leader>bp` | 切换固定缓冲区     | n    |
| `<leader>bP` | 删除未固定的缓冲区 | n    |
| `<leader>br` | 删除右侧缓冲区     | n    |
| `[b`         | 上一个缓冲区       | n    |
| `]b`         | 下一个缓冲区       | n    |
| `<S-h>`      | 上一个缓冲区       | n    |
| `<S-l>`      | 下一个缓冲区       | n    |

### [conform.nvim](https://github.com/stevearc/conform.nvim.git)

这个快捷键用于格式化代码中嵌入的语言片段，比如在 HTML 文件中的 JavaScript 或 CSS 代码。这可以在普通模式和可视模式下使用，非常适合快速整理和标准化混合语言代码的格式。

| 键位         | 描述           | 模式 |
| ------------ | -------------- | ---- |
| `<leader>cF` | 格式化嵌入语言 | n, v |

### [flash.nvim](https://github.com/folke/flash.nvim.git)

这些快捷键涉及到快速搜索和代码解析功能。"闪电搜索"可能是一个用于快速定位或模式匹配的功能，而 "Treesitter 搜索" 则利用 Treesitter 的语法树功能来进行更精确的代码分析和搜索。

| 键位    | 描述                | 模式    |
| ------- | ------------------- | ------- |
| `<c-s>` | 切换闪电搜索        | c       |
| `r`     | 远程闪电搜索        | o       |
| `R`     | Treesitter 搜索     | o, x    |
| `s`     | 闪电搜索            | n, o, x |
| `S`     | Treesitter 闪电搜索 | n, o, x |

### [mason.nvim](https://github.com/williamboman/mason.nvim.git)

`mason.nvim` 是一个流行的插件，用于管理和安装语言服务器、linter、格式化程序以及其他开发相关工具，方便用户在 NeoVim 环境中轻松维护这些工具。

| 键位         | 描述                | 模式 |
| ------------ | ------------------- | ---- |
| `<leader>cm` | 打开 Mason 控制面板 | n    |

### [mini.bufremove](https://github.com/echasnovski/mini.bufremove.git)

这些快捷键用于管理 NeoVim 中的缓冲区（通常对应打开的文件）。

| 键位         | 描述           | 模式 |
| ------------ | -------------- | ---- |
| `<leader>bd` | 删除缓冲区     | n    |
| `<leader>bD` | 强制删除缓冲区 | n    |

### [mini.pairs](https://github.com/echasnovski/mini.pairs.git)

这个快捷键 `<leader>up` 用于在普通模式下开启或关闭自动配对功能，这通常指的是自动插入闭合的括号、引号等符号，以便在编程时提高效率。例如，当您输入一个左括号 `(` 时，自动配对会立即添加右括号 `)`，并将光标定位在两个括号之间。

| 键位         | 描述         | 模式 |
| ------------ | ------------ | ---- |
| `<leader>up` | 切换自动配对 | n    |

### [mini.surround](https://github.com/echasnovski/mini.surround.git)

`mini.surround` 是一个 NeoVim 插件，用于快速添加、删除、查找或替换文本周围的“包围”元素（如括号、引号等）。

| 键位  | 描述                                    | 模式 |
| ----- | --------------------------------------- | ---- |
| `gsa` | 添加包围                                | n, v |
| `gsd` | 删除包围                                | n    |
| `gsf` | 查找右侧包围                            | n    |
| `gsF` | 查找左侧包围                            | n    |
| `gsh` | 高亮显示包围                            | n    |
| `gsn` | 更新 `MiniSurround.config.n_lines` 设置 | n    |
| `gsr` | 替换包围                                | n    |

### [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim.git)

`neo-tree.nvim` 是一个 NeoVim 插件，提供一个侧边栏界面用于浏览文件、缓冲区和与 Git 相关的操作。这些快捷键允许你快速访问和操作文件系统和版本控制系统

| 键位         | 描述                                    | 模式 |
| ------------ | --------------------------------------- | ---- |
| `<leader>be` | 缓冲区浏览器                            | n    |
| `<leader>e`  | 打开 NeoTree 文件浏览器（根目录）       | n    |
| `<leader>E`  | 打开 NeoTree 文件浏览器（当前工作目录） | n    |
| `<leader>fe` | 打开 NeoTree 文件浏览器（根目录）       | n    |
| `<leader>fE` | 打开 NeoTree 文件浏览器（当前工作目录） | n    |
| `<leader>ge` | Git 浏览器                              | n    |

### [noice.nvim](https://github.com/folke/noice.nvim.git)

`noice.nvim` 是一个 NeoVim 插件，用于增强和管理 NeoVim 的通知系统，提供了更丰富的用户界面交互方式。

| 键位          | 描述             | 模式    |
| ------------- | ---------------- | ------- |
| `<c-b>`       | 向后滚动         | n, i, s |
| `<c-f>`       | 向前滚动         | n, i, s |
| `<leader>sna` | 显示所有通知     | n       |
| `<leader>snd` | 消除所有通知     | n       |
| `<leader>snh` | 查看通知历史     | n       |
| `<leader>snl` | 显示最后一条通知 | n       |
| `<S-Enter>`   | 重定向命令行     | c       |

### [nvim-notify](https://github.com/rcarriga/nvim-notify.git)

`nvim-notify` 是一个 NeoVim 插件，用于提供一个漂亮的、可定制的通知系统。

| 键位         | 描述         | 模式 |
| ------------ | ------------ | ---- |
| `<leader>un` | 消除所有通知 | n    |

### [nvim-spectre](https://github.com/nvim-pack/nvim-spectre.git)

`nvim-spectre` 是一个 NeoVim 插件，用于在项目中查找和替换文本。

| 键位         | 描述                    | 模式 |
| ------------ | ----------------------- | ---- |
| `<leader>sr` | 在文件中替换（Spectre） | n    |

### [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter.git)

`nvim-treesitter` 是一个基于 Treesitter 的 NeoVim 插件，它使用语法树来提高代码的语法高亮、折叠和其他语义相关的功能的质量和性能。

| 键位        | 描述         | 模式 |
| ----------- | ------------ | ---- |
| `<bs>`      | 减少选择范围 | x    |
| `<c-space>` | 增加选择范围 | n    |

### [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context.git)

`nvim-treesitter-context` 是一个基于 Treesitter 的 NeoVim 插件，它用来显示当前代码块的上下文信息（例如，你在一个很长的函数内部编辑时，它可以在屏幕顶部显示函数的声明）。

| 键位         | 描述                       | 模式 |
| ------------ | -------------------------- | ---- |
| `<leader>ut` | 切换 Treesitter 上下文显示 | n    |

### [persistence.nvim](https://github.com/folke/persistence.nvim.git)

`persistence.nvim` 是一个 NeoVim 插件，用于管理编辑器的会话，使用户可以保存当前的工作状态，包括打开的文件、窗口布局等，并在之后重新加载这些状态。

| 键位         | 描述           | 模式 |
| ------------ | -------------- | ---- |
| `<leader>qd` | 不保存当前会话 | n    |
| `<leader>ql` | 恢复上一个会话 | n    |
| `<leader>qs` | 恢复会话       | n    |

### [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim.git)

`telescope.nvim` 是一个功能强大的文件、缓冲区、标记等搜索工具，适用于 NeoVim。

| 键位              | 描述                               | 模式 |
| ----------------- | ---------------------------------- | ---- |
| `<leader><space>` | 在根目录中查找文件                 | n    |
| `<leader>,`       | 切换缓冲区                         | n    |
| `<leader>/`       | 在根目录中使用 Grep 搜索           | n    |
| `<leader>:`       | 命令历史                           | n    |
| `<leader>fb`      | 缓冲区                             | n    |
| `<leader>fc`      | 查找配置文件                       | n    |
| `<leader>ff`      | 在根目录中查找文件                 | n    |
| `<leader>fF`      | 在当前工作目录中查找文件           | n    |
| `<leader>fg`      | 查找 Git 文件                      | n    |
| `<leader>fr`      | 最近使用的文件                     | n    |
| `<leader>fR`      | 在当前工作目录中查找最近使用的文件 | n    |
| `<leader>gc`      | 提交历史                           | n    |
| `<leader>gs`      | Git 状态                           | n    |
| `<leader>s"`      | 寄存器                             | n    |
| `<leader>sa`      | 自动命令                           | n    |
| `<leader>sb`      | 缓冲区                             | n    |
| `<leader>sc`      | 命令历史                           | n    |
| `<leader>sC`      | 命令                               | n    |
| `<leader>sd`      | 文档诊断                           | n    |
| `<leader>sD`      | 工作区诊断                         | n    |
| `<leader>sg`      | 在根目录中使用 Grep 搜索           | n    |
| `<leader>sG`      | 在当前工作目录中使用 Grep 搜索     | n    |
| `<leader>sh`      | 帮助页面                           | n    |
| `<leader>sH`      | 搜索高亮组                         | n    |
| `<leader>sk`      | 键映射                             | n    |
| `<leader>sm`      | 跳转到标记                         | n    |
| `<leader>sM`      | Man 页面                           | n    |
| `<leader>so`      | 选项                               | n    |
| `<leader>sR`      | 恢复上次 Telescope 会话            | n    |
| `<leader>ss`      | 跳转到符号                         | n    |
| `<leader>sS`      | 跳转到工作区的符号                 | n    |
| `<leader>sw`      | 在根目录中搜索词汇                 | n    |
| `<leader>sW`      | 在当前工作目录中搜索词汇           | n    |
| `<leader>sw`      | 在根目录中选择搜索                 | v    |
| `<leader>sW`      | 在当前工作目录中选择搜索           | v    |
| `<leader>uC`      | 预览颜色方案                       | n    |

### [todo-comments.nvim](https://github.com/folke/todo-comments.nvim.git)

`todo-comments.nvim` 是一个 NeoVim 插件，专门用于高亮和导航代码中的 TODO、FIXME 等注释。这些快捷键让用户能够快速查找和管理这些特殊注释，有助于保持代码的整洁和维护工作的跟踪

| 键位         | 描述                                     | 模式 |
| ------------ | ---------------------------------------- | ---- |
| `<leader>st` | 显示待办事项注释                         | n    |
| `<leader>sT` | 显示待办事项/修复/待修复注释             | n    |
| `<leader>xt` | 在问题视图中显示待办事项注释             | n    |
| `<leader>xT` | 在问题视图中显示待办事项/修复/待修复注释 | n    |
| `[t`         | 跳转到上一个待办事项注释                 | n    |
| `]t`         | 跳转到下一个待办事项注释                 | n    |

### [trouble.nvim](https://github.com/folke/trouble.nvim.git)

`trouble.nvim` 是一个 NeoVim 插件，用于提供一个结构化的列表视图，显示当前项目中的错误、警告、信息和其他消息。这些快捷键让用户能够更有效地浏览和处理代码中的问题

| 键位         | 描述                                 | 模式 |
| ------------ | ------------------------------------ | ---- |
| `<leader>xL` | 打开问题视图中的位置列表             | n    |
| `<leader>xQ` | 打开问题视图中的快速修复列表         | n    |
| `<leader>xx` | 在问题视图中显示当前文档的诊断信息   | n    |
| `<leader>xX` | 在问题视图中显示整个工作区的诊断信息 | n    |
| `[q`         | 跳转到上一个问题/快速修复项          | n    |
| `]q`         | 跳转到下一个问题/快速修复项          | n    |

### [vim-illuminate](https://github.com/RRethy/vim-illuminate.git)

`vim-illuminate` 是一个 NeoVim 插件，用于高亮显示光标下单词的所有引用，并提供快捷方式在它们之间导航。这些快捷键允许用户在普通模式下快速在文件中的相同引用之间前后跳转

| 键位 | 描述             | 模式 |
| ---- | ---------------- | ---- |
| `[[` | 跳转到上一个引用 | n    |
| `]]` | 跳转到下一个引用 | n    |

### [yanky.nvim](https://github.com/gbprod/yanky.nvim.git)

`yanky.nvim` 是一个扩展 NeoVim 剪贴板和放置功能的插件。这些快捷键提供了丰富的操作，包括管理剪贴历史、应用不同的放置和缩进方式，以及通过应用过滤器来调整放置的内容。

| 键位        | 描述                       | 模式 |
| ----------- | -------------------------- | ---- |
| `<leader>p` | 打开剪贴历史               | n    |
| `<p`        | 放置并向左缩进             | n    |
| `<P`        | 在前方放置并向左缩进       | n    |
| `=p`        | 应用过滤后放置在后方       | n    |
| `=P`        | 应用过滤后放置在前方       | n    |
| `>p`        | 放置并向右缩进             | n    |
| `>P`        | 在前方放置并向右缩进       | n    |
| `[p`        | 在光标前放置并缩进（按行） | n    |
| `[P`        | 在光标前放置并缩进（按行） | n    |
| `[y`        | 在剪贴历史中向前循环       | n    |
| `]p`        | 在光标后放置并缩进（按行） | n    |
| `]P`        | 在光标后放置并缩进（按行） | n    |
| `]y`        | 在剪贴历史中向后循环       | n    |
| `gp`        | 在选择之后放置剪贴文本     | n, x |
| `gP`        | 在选择之前放置剪贴文本     | n, x |
| `p`         | 在光标后放置剪贴文本       | n, x |
| `P`         | 在光标前放置剪贴文本       | n, x |
| `y`         | 复制文本                   | n, x |

### [nvim-dap](https://github.com/mfussenegger/nvim-dap.git)

`nvim-dap` 是一个 NeoVim 的调试协议插件，用于提供类似 IDE 的调试功能。这些快捷键让用户能够在 NeoVim 中直接进行代码调试，包括设置断点、单步执行、查看变量等操作

| 键位         | 描述               | 模式 |
| ------------ | ------------------ | ---- |
| `<leader>da` | 带参数运行         | n    |
| `<leader>db` | 切换断点           | n    |
| `<leader>dB` | 设置断点条件       | n    |
| `<leader>dc` | 继续执行           | n    |
| `<leader>dC` | 运行至光标处       | n    |
| `<leader>dg` | 跳转到行（不执行） | n    |
| `<leader>di` | 步入               | n    |
| `<leader>dj` | 向下一层           | n    |
| `<leader>dk` | 向上一层           | n    |
| `<leader>dl` | 重复上次运行       | n    |
| `<leader>do` | 步出               | n    |
| `<leader>dO` | 步过               | n    |
| `<leader>dp` | 暂停               | n    |
| `<leader>dr` | 切换 REPL          | n    |
| `<leader>ds` | 会话               | n    |
| `<leader>dt` | 终止               | n    |
| `<leader>dw` | 小部件             | n    |

### [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui.git)

`nvim-dap-ui` 是一个 NeoVim 的调试用户界面插件，与 `nvim-dap` 配合使用，为调试会话提供了一个图形界面。这些快捷键让用户能够更直观地管理和观察调试过程

| 键位         | 描述              | 模式 |
| ------------ | ----------------- | ---- |
| `<leader>de` | 评估表达式        | n, v |
| `<leader>du` | 打开 DAP 用户界面 | n    |

### [aerial.nvim](https://github.com/stevearc/aerial.nvim.git)

`aerial.nvim` 是一个 NeoVim 插件，用于提供一个代码结构的侧边栏，显示文件中的符号（如函数、变量等）。

| 键位         | 描述                 | 模式 |
| ------------ | -------------------- | ---- |
| `<leader>cs` | 打开 Aerial 符号列表 | n    |

### [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim.git)

这个快捷键使得用户可以通过 `telescope.nvim` 结合 `aerial.nvim` 的功能，在普通模式下快速跳转到当前文件中的任意符号（如函数、变量等）。

| 键位         | 描述                 | 模式 |
| ------------ | -------------------- | ---- |
| `<leader>ss` | 跳转到符号（Aerial） | n    |

### [dial.nvim](https://github.com/monaqa/dial.nvim.git)

`dial.nvim` 是一个 NeoVim 插件，用于在可编辑文本中增加或减少数字、日期、十六进制数值等元素。这些快捷键允许用户在普通模式和可视模式下调整各种元素的值

| 键位     | 描述 | 模式 |
| -------- | ---- | ---- |
| `<C-a>`  | 增加 | n, v |
| `<C-x>`  | 减少 | n, v |
| `g<C-a>` | 增加 | n, v |
| `g<C-x>` | 减少 | n, v |

### [harpoon](https://github.com/ThePrimeagen/harpoon.git)

`harpoon` 是一个 NeoVim 插件，提供了一种便捷的方式来标记和快速切换到常用的文件。这些快捷键允许用户在普通模式下进行如下操作

| 键位        | 描述                   | 模式 |
| ----------- | ---------------------- | ---- |
| `<leader>1` | 跳转到 Harpoon 文件 1  | n    |
| `<leader>2` | 跳转到 Harpoon 文件 2  | n    |
| `<leader>3` | 跳转到 Harpoon 文件 3  | n    |
| `<leader>4` | 跳转到 Harpoon 文件 4  | n    |
| `<leader>5` | 跳转到 Harpoon 文件 5  | n    |
| `<leader>h` | 打开 Harpoon 快速菜单  | n    |
| `<leader>H` | 标记当前文件到 Harpoon | n    |

### [flit.nvim](https://github.com/ggandor/flit.nvim.git)

`flit.nvim` 是一个 NeoVim 插件，提供了一种快速定位到文件中特定字符的方法。这些快捷键允许用户在普通模式、运算符等待模式和可视模式下快速跳转

| 键位 | 描述                   | 模式    |
| ---- | ---------------------- | ------- |
| `f`  | 向前跳转到下一个字符   | n, o, x |
| `F`  | 向后跳转到前一个字符   | n, o, x |
| `t`  | 向前跳转到目标字符之前 | n, o, x |
| `T`  | 向后跳转到目标字符之后 | n, o, x |

### [leap.nvim](https://github.com/ggandor/leap.nvim.git)

`leap.nvim` 是一个 NeoVim 插件，提供了高效的跳转功能，可以快速在文档内或跨多个窗口导航至指定位置。这些快捷键让用户能够在普通模式、运算符等待模式和可视模式下进行如下操作

| 键位 | 描述               | 模式    |
| ---- | ------------------ | ------- |
| `gs` | 从窗口间跳跃       | n, o, x |
| `s`  | 向前跳跃至指定字符 | n, o, x |
| `S`  | 向后跳跃至指定字符 | n, o, x |

### [mini.diff](https://github.com/echasnovski/mini.diff.git)

`mini.diff` 是一个 NeoVim 插件，用于显示和管理代码更改的可视化叠加。这个快捷键 `<leader>go` 允许用户在普通模式下快速开启或关闭这种叠加显示，方便查看从上次提交以来所做的更改

| 键位         | 描述                    | 模式 |
| ------------ | ----------------------- | ---- |
| `<leader>go` | 切换 mini.diff 叠加显示 | n    |

### [mini.files](https://github.com/echasnovski/mini.files.git)

`mini.files` 是一个 NeoVim 插件，用于提供文件浏览和选择的界面。这些快捷键让用户能够在普通模式下方便地浏览和打开文件

| 键位         | 描述                                 | 模式 |
| ------------ | ------------------------------------ | ---- |
| `<leader>fm` | 打开 mini.files （当前文件所在目录） | n    |
| `<leader>fM` | 打开 mini.files （当前工作目录）     | n    |

### [outline.nvim](https://github.com/hedyhli/outline.nvim.git)

`outline.nvim` 是一个 NeoVim 插件，用于显示当前编辑文件的结构大纲，包括函数、类、标签等元素。这个快捷键 `<leader>cs` 允许用户在普通模式下快速开启或关闭大纲视图

| 键位         | 描述         | 模式 |
| ------------ | ------------ | ---- |
| `<leader>cs` | 切换大纲视图 | n    |

### [trouble.nvim](https://github.com/folke/trouble.nvim.git)

`trouble.nvim` 是一个 NeoVim 插件，用于提供一个结构化的列表视图，显示当前项目中的错误、警告、信息和其他消息。

| 键位         | 描述                                 | 模式 |
| ------------ | ------------------------------------ | ---- |
| `<leader>cs` | 显示符号（Trouble）                  | n    |
| `<leader>cS` | 显示 LSP 引用/定义等（Trouble）      | n    |
| `<leader>xL` | 打开问题视图中的位置列表             | n    |
| `<leader>xQ` | 打开问题视图中的快速修复列表         | n    |
| `<leader>xx` | 在问题视图中显示当前文档的诊断信息   | n    |
| `<leader>xX` | 在问题视图中显示当前缓冲区的诊断信息 | n    |
| `[q`         | 跳转到上一个问题/快速修复项          | n    |

### [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim.git)

`markdown-preview.nvim` 是一个 NeoVim 插件，用于实时预览 Markdown 文件。这个快捷键 `<leader>cp` 允许用户在普通模式下快速开启或关闭 Markdown 文件的预览视图：

| 键位         | 描述          | 模式 |
| ------------ | ------------- | ---- |
| `<leader>cp` | Markdown 预览 | n    |

### [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python.git)

`nvim-dap-python` 是一个针对 Python 开发集成的 NeoVim 调试插件，部分扩展自 `nvim-dap`，专门用于 Python 代码的调试。

| 键位          | 描述     | 模式 |
| ------------- | -------- | ---- |
| `<leader>dPc` | 调试类   | n    |
| `<leader>dPt` | 调试方法 | n    |

### [venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim.git)

`venv-selector.nvim` 是一个专为 Python 开发设计的 NeoVim 插件，用于管理和选择 Python 虚拟环境。

| 键位         | 描述         | 模式 |
| ------------ | ------------ | ---- |
| `<leader>cv` | 选择虚拟环境 | n    |

### [neotest](https://github.com/nvim-neotest/neotest.git)

 `neotest` 是一个 NeoVim 插件，专为提升测试的便捷性和效率而设计。

| 键位         | 描述               | 模式 |
| ------------ | ------------------ | ---- |
| `<leader>tl` | 运行上一次测试     | n    |
| `<leader>to` | 显示测试输出       | n    |
| `<leader>tO` | 切换输出面板       | n    |
| `<leader>tr` | 运行最近的测试     | n    |
| `<leader>ts` | 切换摘要视图       | n    |
| `<leader>tS` | 停止测试           | n    |
| `<leader>tt` | 运行当前文件的测试 | n    |
| `<leader>tT` | 运行所有测试文件   | n    |

### [nvim-dap](https://github.com/mfussenegger/nvim-dap.git)

这个快捷键 `<leader>td` 是 `nvim-dap` 的一部分，专门用于在普通模式下启动对最接近光标位置的测试函数或代码块的调试会话。

| 键位         | 描述           | 模式 |
| ------------ | -------------- | ---- |
| `<leader>td` | 调试最近的测试 | n    |

### [edgy.nvim](https://github.com/folke/edgy.nvim.git)

`edgy.nvim` 是一个 NeoVim 插件，用于改进窗口管理和视觉布局。

| 键位         | 描述           | 模式 |
| ------------ | -------------- | ---- |
| `<leader>ue` | 切换 Edgy 界面 | n    |
| `<leader>uE` | 选择 Edgy 窗口 | n    |

### [mason.nvim](https://github.com/williamboman/mason.nvim.git)

`mason.nvim` 是一个 NeoVim 插件，通常用于管理语言服务器、Linter、格式化工具等开发工具。这里提到的 GitUi 是一个独立的 Git 用户界面，使得用户可以在 NeoVim 中以图形化的方式管理 Git 仓库。

| 键位         | 描述                       | 模式 |
| ------------ | -------------------------- | ---- |
| `<leader>gg` | 打开 GitUi（根目录）       | n    |
| `<leader>gG` | 打开 GitUi（当前工作目录） | n    |

### [project.nvim](https://github.com/ahmedkhalf/project.nvim.git)

`project.nvim` 是一个 NeoVim 插件，用于管理和快速切换不同的项目。这个快捷键 `<leader>fp` 允许用户在普通模式下快速访问已保存的项目列表

| 键位         | 描述         | 模式 |
| ------------ | ------------ | ---- |
| `<leader>fp` | 打开项目列表 | n    |
