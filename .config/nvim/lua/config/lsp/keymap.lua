-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

local M = {}

--- Setup LSP-related keymaps for the given buffer.
---@param buf integer
function M.setup(buf)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
  end

  -- Snacks-based LSP pickers
  map("n", "gd", Snacks.picker.lsp_definitions, "Goto Definition")
  map("n", "gD", Snacks.picker.lsp_declarations, "Goto Declaration")
  map("n", "gr", Snacks.picker.lsp_references, "References")
  map("n", "gI", Snacks.picker.lsp_implementations, "Goto Implementation")
  map("n", "gy", Snacks.picker.lsp_type_definitions, "Goto Type Definition")
  map("n", "<leader>ss", Snacks.picker.lsp_symbols, "Document Symbols")
  map("n", "<leader>sS", Snacks.picker.lsp_workspace_symbols, "Workspace Symbols")

  -- Classic LSP bindings
  map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
  -- map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous Diagnostic")
  map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next Diagnostic")
  map("n", "<leader>d", vim.diagnostic.open_float, "Show Diagnostic")
  map("n", "<leader>q", vim.diagnostic.setloclist, "Quickfix Diagnostics")

  map("n", "<leader>uf", function() require("config.lsp.format").toggle() end, "Toggle Autoformat-on-Save")
  map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format Buffer")
end

return M
