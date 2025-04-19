-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

local M = {}

-- Toggle state (defaults to enabled)
M.autoformat_enabled = true

function M.toggle()
  M.autoformat_enabled = not M.autoformat_enabled
  vim.notify("[lsp/format] Autoformat " .. (M.autoformat_enabled and "enabled" or "disabled"))
end

-- LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp.format", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    -- Only if server supports formatting and we want it
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("lsp.format." .. args.buf, { clear = true }),
        buffer = args.buf,
        callback = function()
          if M.autoformat_enabled then
            vim.lsp.buf.format({
              bufnr = args.buf,
              timeout_ms = 1000,
              filter = function(cl)
                -- Only format with attached client
                return cl.id == client.id
              end,
            })
          end
        end,
      })
    end
  end,
})

return M
