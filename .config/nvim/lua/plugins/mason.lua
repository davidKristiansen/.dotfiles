-- lua/plugins/lsp.lua
-- SPDX-License-Identifier: MIT
vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
}, { confirm = false })

local mason = require "mason"
local mason_lspconfig = require "mason-lspconfig"

local servers = {
  -- "basedpyright",
  "ty",
  "bashls",
  "clangd",
  "copilot",
  "jsonls",
  "lua_ls",
  "ruff",
  "yamlls",
}

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

mason_lspconfig.setup({
  ensure_installed = servers,
  automatic_installation = true,
})
