-- SPDX-License-Identifier: MIT

local M = {}

function M.setup(bufnr)
  local map = function(mode, lhs, rhs, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  -- Navigation
  map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
  map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
  map("n", "grr", vim.lsp.buf.references, "List References")
  map("n", "gri", vim.lsp.buf.implementation, "Go to Implementation")
  map("n", "gra", vim.lsp.buf.code_action, "Code Actions")
  map("n", "grt", vim.lsp.buf.type_definition, "Go to Type Definition")
  map("n", "grn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>cf", function() vim.lsp.buf.format { async = true } end, "Format Document")

  -- Documentation
  map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
  map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

  -- Refactoring
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

  -- Diagnostics
  map("n", "gl", vim.diagnostic.open_float, "Line Diagnostics")
  map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
end

return M
