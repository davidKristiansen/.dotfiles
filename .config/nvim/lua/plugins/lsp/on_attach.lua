-- lua/plugins/lsp/on_attach.lua
-- SPDX-License-Identifier: MIT
local M = {}

function M.setup(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client then return end

  -- Setup buffer-local keymaps
  require("plugins.lsp.keymaps").setup(ev.buf)

  -- Enable features based on server capabilities
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
  end

  vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

  -- On-type formatting
  local otf = vim.lsp.on_type_formatting
  local deny = { tsserver = true } -- example: turn off for specific servers
  if otf and type(otf.enable) == "function"
      and client.supports_method
      and client:supports_method("textDocument/onTypeFormatting")
      and not deny[client.name]
  then
    otf.enable(true, { bufnr = ev.buf, client_id = client.id })
    vim.api.nvim_buf_create_user_command(ev.buf, "LspOnTypeFormatToggle", function()
      local enabled = false
      if type(otf.is_enabled) == "function" then
        enabled = otf.is_enabled({ bufnr = ev.buf })
      end
      otf.enable(not enabled, { bufnr = ev.buf, client_id = client.id })
      vim.notify(("OnTypeFormatting: %s (%s)"):format(not enabled and "ON" or "OFF", client.name))
    end, {})
  end

  -- Format on save
  if client.server_capabilities.documentFormattingProvider then
    local format_on_save_enabled = false
    local group_name = "lsp_format_on_save_" .. ev.buf

    local function enable_format_on_save()
      if not format_on_save_enabled then
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = vim.api.nvim_create_augroup(group_name, { clear = true }),
          buffer = ev.buf,
          callback = function()
            vim.lsp.buf.format({ async = false, bufnr = ev.buf })
          end,
        })
        format_on_save_enabled = true
        vim.notify("LSP format on save: ON")
      end
    end

    local function disable_format_on_save()
      vim.api.nvim_clear_autocmds({ group = group_name, buffer = ev.buf })
      format_on_save_enabled = false
      vim.notify("LSP format on save: OFF")
    end

    vim.api.nvim_buf_create_user_command(ev.buf, "LspFormatOnSaveToggle", function()
      if format_on_save_enabled then
        disable_format_on_save()
      else
        enable_format_on_save()
      end
    end, { desc = "Toggle LSP format on save" })
  end
end

return M
