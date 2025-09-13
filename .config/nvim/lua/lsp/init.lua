-- lua/lsp/init.lua
-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  -- IMPORTANT: when using lspconfig, you do NOT need vim.lsp.enable(...)
  -- lspconfig starts servers on matching filetypes.

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_core", { clear = true }),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if not client then return end

      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
      end

      map("n", "K", vim.lsp.buf.hover, "LSP Hover")
      map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
      map("n", "gr", vim.lsp.buf.references, "List References")
      map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
      map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
      map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      -- Removed buffer-local <leader>cf (format) to prefer global mapping in core/keymaps.lua
    end,
  })
end

return M
