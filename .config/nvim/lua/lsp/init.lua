-- lua/lsp/init.lua
-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_core", { clear = true }),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if not client then return end

      -- basic maps
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
      end
      vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
      map("n", "K", vim.lsp.buf.hover, "LSP Hover")
      map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
      map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
      map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
      map("n", "gr", vim.lsp.buf.references, "List References")
      map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      map({ "n", "i" }, "<C-S-k>", vim.lsp.buf.signature_help, "Signature Help")
      map("n", "gl", vim.diagnostic.open_float, "Line Diagnostics")

      -- Inlay hints (NVIM ≥ 0.10)
      if vim.lsp.inlay_hint and client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      end

      -- ===== OnTypeFormatting (NVIM 0.12+) =====
      -- guard for older nvim / weird builds
      local otf = vim.lsp.on_type_formatting
      local deny = { tsserver = true } -- example: turn off for specific servers

      if otf and type(otf.enable) == "function"
          and client.supports_method
          and client:supports_method("textDocument/onTypeFormatting")
          and not deny[client.name]
      then
        -- enable for this buffer & client
        otf.enable(true, { bufnr = ev.buf, client_id = client.id })

        -- buffer-local toggle command
        vim.api.nvim_buf_create_user_command(ev.buf, "LspOnTypeFormatToggle", function()
          local enabled = false
          if type(otf.is_enabled) == "function" then
            enabled = otf.is_enabled({ bufnr = ev.buf })
          end
          otf.enable(not enabled, { bufnr = ev.buf, client_id = client.id })
          vim.notify(("OnTypeFormatting: %s (%s)"):format(not enabled and "ON" or "OFF", client.name))
        end, {})

        -- optional keymap to flip quickly
        map("n", "<leader>co", "<cmd>LspOnTypeFormatToggle<CR>", "Toggle On-Type Formatting")
      end

      -- Format on save (disabled by default, can be toggled)
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

        map("n", "<leader>cf", "<cmd>LspFormatOnSaveToggle<CR>", "Toggle Format on Save")
        -- Disabled by default. Call :LspFormatOnSaveToggle to enable per buffer.
      end
    end,
  })
end

return M
