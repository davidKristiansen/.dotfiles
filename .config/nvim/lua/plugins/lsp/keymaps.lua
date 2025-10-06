-- lua/plugins/lsp/keymaps.lua
-- SPDX-License-Identifier: MIT
local M = {}

function M.setup(bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("n", "K", vim.lsp.buf.hover, "LSP Hover")
  map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
  map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
  map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
  map("n", "gr", vim.lsp.buf.references, "List References")
  map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map({ "n", "i" }, "<C-S-k>", vim.lsp.buf.signature_help, "Signature Help")
  map("n", "gl", vim.diagnostic.open_float, "Line Diagnostics")
  map("n", "<leader>co", "<cmd>LspOnTypeFormatToggle<CR>", "Toggle On-Type Formatting")
  map("n", "<leader>cs", "<cmd>LspFormatOnSaveToggle<CR>", "Toggle Format on Save")
  map("n", "<leader>cs", vim.lsp.buf.format(), "Toggle Format on Save")
end

return M
