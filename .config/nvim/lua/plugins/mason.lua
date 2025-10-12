-- lua/plugins/lsp.lua
-- SPDX-License-Identifier: MIT

local M = {}

function M.setup()
  local mason = require "mason"
  local mason_lspconfig = require "mason-lspconfig"

  local servers = {
    "basedpyright",
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

end

return M
