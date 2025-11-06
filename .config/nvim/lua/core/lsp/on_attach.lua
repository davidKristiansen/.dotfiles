-- lua/core/lsp/on_attach.lua
-- SPDX-License-Identifier: MIT

vim.g.format_on_save             = true
vim.g.inlay_hints_enabled        = false
vim.g.on_type_formatting_enabled = true
vim.g.fix_all_on_save            = false

local keymaps                    = require "core.lsp.keymaps"
local fixall                     = require "core.lsp.fix_all"

return function(args)
  local bufnr = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if not client then return end

  keymaps.setup(bufnr)

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr)
      and vim.g.inlay_hints_enabled then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_onTypeFormatting, bufnr)
      and vim.g.on_type_formatting_enabled then
    vim.lsp.on_type_formatting.enable(true, { bufnr = bufnr })
  end

  -- install the pipeline for this buffer too (harmless if you also call setup())
  fixall.attach(bufnr)

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
    vim.keymap.set('i', '<C-F>', vim.lsp.inline_completion.get,
      { desc = 'LSP: accept inline completion', buffer = bufnr })
    vim.keymap.set('i', '<C-G>', vim.lsp.inline_completion.select,
      { desc = 'LSP: switch inline completion', buffer = bufnr })
  end
end
