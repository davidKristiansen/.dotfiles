-- lua/lsp/on_attach.lua
-- SPDX-License-Identifier: MIT
local M = {}

-- Supports being called as:
--   1) From LspAttach autocmd: M.setup(ev)
--   2) From lspconfig on_attach callback: M.setup(client, bufnr)
function M.setup(arg1, arg2)
  local client, bufnr
  if type(arg1) == 'table' and arg1.data and arg1.buf and not arg2 then
    local ev = arg1
    client = vim.lsp.get_client_by_id(ev.data.client_id)
    bufnr = ev.buf
  else
    client = arg1
    bufnr = arg2
  end
  if not client or not bufnr then return end

  -- Setup buffer-local keymaps
  require("lsp.keymaps").setup(bufnr)

  -- Enable features based on server capabilities (multi-client safe)
  local function any_inlay_client()
    for _, c in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      if c.server_capabilities and c.server_capabilities.inlayHintProvider then
        return true
      end
    end
    return false
  end
  if vim.lsp.inlay_hint and any_inlay_client() then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
  if not vim.b[bufnr].lsp_inlay_hint_toggle_cmd_created then
    vim.api.nvim_buf_create_user_command(bufnr, "LspInlayHintToggle", function()
      if not vim.lsp.inlay_hint then return end
      if not any_inlay_client() then
        -- vim.notify("Inlay hints not supported by any attached LSP", vim.log.levels.WARN)
        return
      end
      local enabled = true
      if type(vim.lsp.inlay_hint.is_enabled) == "function" then
        enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
      end
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      -- vim.notify(("InlayHints: %s"):format(not enabled and "ON" or "OFF"))
    end, { desc = "Toggle LSP inlay hints" })
    vim.b[bufnr].lsp_inlay_hint_toggle_cmd_created = true
  end

  -- Inline completion (Neovim nightly feature)
  if client.supports_method and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion) then
    if vim.lsp.inline_completion and vim.lsp.inline_completion.enable then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
      vim.keymap.set('i', '<C-F>', vim.lsp.inline_completion.get, { desc = 'LSP: accept inline completion', buffer = bufnr })
      vim.keymap.set('i', '<C-G>', vim.lsp.inline_completion.select, { desc = 'LSP: switch inline completion', buffer = bufnr })
    end
  end

  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

  -- On-type formatting
  local otf = vim.lsp.on_type_formatting
  local deny = { tsserver = true } -- example: turn off for specific servers
  if otf and type(otf.enable) == "function"
      and client.supports_method
      and client:supports_method("textDocument/onTypeFormatting")
      and not deny[client.name]
  then
    otf.enable(true, { bufnr = bufnr, client_id = client.id })
    vim.api.nvim_buf_create_user_command(bufnr, "LspOnTypeFormatToggle", function()
      local enabled = false
      if type(otf.is_enabled) == "function" then
        enabled = otf.is_enabled({ bufnr = bufnr })
      end
      otf.enable(not enabled, { bufnr = bufnr, client_id = client.id })
      vim.notify(("OnTypeFormatting: %s (%s)"):format(not enabled and "ON" or "OFF", client.name))
    end, {})
  end

  -- Format on save
  if client.server_capabilities.documentFormattingProvider then
    local format_on_save_enabled = false
    local group_name = "lsp_format_on_save_" .. bufnr

    local function enable_format_on_save()
      if not format_on_save_enabled then
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = vim.api.nvim_create_augroup(group_name, { clear = true }),
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false, bufnr = bufnr })
          end,
        })
        format_on_save_enabled = true
        vim.notify("LSP format on save: ON")
      end
    end

    local function disable_format_on_save()
      vim.api.nvim_clear_autocmds({ group = group_name, buffer = bufnr })
      format_on_save_enabled = false
      vim.notify("LSP format on save: OFF")
    end

    vim.api.nvim_buf_create_user_command(bufnr, "LspFormatOnSaveToggle", function()
      if format_on_save_enabled then
        disable_format_on_save()
      else
        enable_format_on_save()
      end
    end, { desc = "Toggle LSP format on save" })
  end
end

return M
