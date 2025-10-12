-- SPDX-License-Identifier: MIT


vim.g.format_on_save = true

local keymaps = require "core.lsp.keymaps"

-- Keymaps for LSP features.
-- See `:help vim.lsp.buf` for more information.
return function(client, bufnr)
  if not client then return end

  keymaps.setup(bufnr)

  vim.lsp.inlay_hint.enable(true)
  vim.lsp.on_type_formatting.enable(true)
  vim.lsp.inline_completion.enable(true)


  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
      if not vim.g.format_on_save then return end
      vim.lsp.buf.format { async = false }
    end,
  })
end
