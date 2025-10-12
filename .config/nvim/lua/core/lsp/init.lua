-- SPDX-License-Identifier: MIT

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = require "core.lsp.on_attach"
})
