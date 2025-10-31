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
  map("n", "gd", function() require("telescope.builtin").lsp_definitions() end, "Go to Definition")
  map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
  map("n", "gvD", function() vim.lsp.buf.declaration({ jump_to_location_opts = { command = "vsplit" } }) end, "Go to Declaration (Vertical Split)")
  map("n", "grr", function() require("telescope.builtin").lsp_references() end, "List References")
  map("n", "gri", function() require("telescope.builtin").lsp_implementations() end, "Go to Implementation")
  map("n", "gra", vim.lsp.buf.code_action, "Code Actions")
  map("n", "grt", function() require("telescope.builtin").lsp_type_definitions() end, "Go to Type Definition")
  map("n", "grn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>cf", function() vim.lsp.buf.format { async = true } end, "Format Document")

  -- Documentation
  map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
  map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

  -- Refactoring
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

  -- Diagnostics
  map("n", "gl", function() require("telescope.builtin").diagnostics() end, "Line Diagnostics")
  map("n", "[d", function() vim.diagnostic.goto(true) end, "Previous Diagnostic")
  map("n", "]d", function() vim.diagnostic.goto(false) end, "Next Diagnostic")
end

return M
