-- lua/plugins/lsp/init.lua
-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  vim.pack.add({
    -- LSP / Language Tooling
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
  }, { load = true })

  -- Setup Mason
  require("mason").setup({
    ui = { border = "rounded" },
  })

  -- Per-plugin setups
  require("plugins.lsp.settings").setup()
end

return M
