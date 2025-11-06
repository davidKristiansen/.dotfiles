-- init.lua
-- SPDX-License-Identifier: MIT

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = require("core.lsp.on_attach"),
})

require("core.lsp.fix_all").setup({
  enable_on_save = true,
  filetypes = { "python" },
  create_commands = true,
  create_mappings = true,
  mapping_run = "<leader>fa",
  mapping_toggle = "<leader>ta",
})
