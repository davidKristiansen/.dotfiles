-- init.lua
-- SPDX-License-Identifier: MIT

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = require("core.lsp.on_attach"),
})

require("core.lsp.fix_all").setup({
  enable_on_save = true,
  create_commands = true,
})
