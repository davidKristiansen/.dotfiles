-- lua/core/lsp/on_attach.lua
-- SPDX-License-Identifier: MIT
-- Per-buffer LspAttach handler; global toggle defaults live in core.lsp.init.

local keymaps = require('core.lsp.keymaps')

return function(args)
  local bufnr = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if not client then
    return
  end

  keymaps.setup(bufnr)

  if
    client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr)
    and vim.g.inlay_hints_enabled
  then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  if
    client:supports_method(vim.lsp.protocol.Methods.textDocument_onTypeFormatting, bufnr)
    and vim.g.on_type_formatting_enabled
  then
    vim.lsp.on_type_formatting.enable(true, { bufnr = bufnr })
  end

  ---------------------------------------------------------------------------
  -- Inline completion: ONLY enable for specific AI-ish LSPs, not clangd.
  ---------------------------------------------------------------------------
  local inline_clients = {
    copilot = true,
    -- supermaven = true,
    -- your_ai_server = true,
  }

  if
    inline_clients[client.name]
    and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr)
  then
    -- NOTE: we ONLY pass bufnr here, NOT client_id
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

    vim.keymap.set('i', '<C-F>', vim.lsp.inline_completion.get, {
      desc = 'LSP: accept inline completion',
      buffer = bufnr,
    })

    vim.keymap.set('i', '<C-G>', vim.lsp.inline_completion.select, {
      desc = 'LSP: switch inline completion',
      buffer = bufnr,
    })
  end
end
