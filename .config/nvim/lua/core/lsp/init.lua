-- init.lua
-- SPDX-License-Identifier: MIT

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = require("core.lsp.on_attach"),
})

-- FixAll is intentionally NOT run on save (it can be destructive — e.g.
-- removing "unused" imports/vars, and is risky for C). It stays manual via
-- the <leader>cA keymap and the :LspFixAll command. Per-buffer opt-in to
-- on-save is still available through <leader>Ta / :LspFixAllToggle.
require("core.lsp.fix_all").setup({
  enable_on_save = false,
  create_commands = true,
})
