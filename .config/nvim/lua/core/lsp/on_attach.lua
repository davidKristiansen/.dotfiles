-- SPDX-License-Identifier: MIT


vim.g.format_on_save = true

local keymaps = require "core.lsp.keymaps"

-- Keymaps for LSP features.
-- See `:help vim.lsp.buf` for more information.
return function(args)
  local bufnr = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)

  if not client then return end

  keymaps.setup(bufnr)

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr) then
    if vim.g.inlay_hints_enabled == nil then
      vim.g.inlay_hints_enabled = true
    end
    if vim.g.inlay_hints_enabled then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_onTypeFormatting, bufnr) then
    if vim.g.on_type_formatting_enabled == nil then
      vim.g.on_type_formatting_enabled = true
    end
    if vim.g.on_type_formatting_enabled then
      vim.lsp.on_type_formatting.enable(true, { bufnr = bufnr })
    end
  end

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_formatting, bufnr) then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if not vim.g.format_on_save then return end
        vim.lsp.buf.format { async = false }
      end,
    })
  end

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

    vim.keymap.set(
      'i',
      '<C-F>',
      vim.lsp.inline_completion.get,
      { desc = 'LSP: accept inline completion', buffer = bufnr }
    )
    vim.keymap.set(
      'i',
      '<C-G>',
      vim.lsp.inline_completion.select,
      { desc = 'LSP: switch inline completion', buffer = bufnr }
    )
  end
end
