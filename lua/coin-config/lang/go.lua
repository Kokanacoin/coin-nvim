local lspconfig = require("lspconfig")

-- 配置 Golang LSP (gopls)
lspconfig.gopls.setup({
  on_attach = function(_, bufnr)
    local function buf_set_keymap(mode, lhs, rhs, opts)
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    local function buf_set_option(option, value)
      vim.api.nvim_buf_set_option(bufnr, option, value)
    end

    buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
  end,

  filetypes = { "go", "gomod" },
})
