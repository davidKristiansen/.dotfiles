-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

require("config.lsp.format")

local M = {}

local lsp = vim.lsp

--- Logs when an LSP client attaches.
function M.log_on_attach()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = lsp.get_client_by_id(args.data.client_id)
      vim.notify("[LSP] Attached: " .. (client and client.name or "unknown"))
    end,
  })
end

--- Sets up keymaps for LSP when a client attaches.
---@param setup_fn fun(buf: integer)
function M.setup_keymaps(setup_fn)
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user.lsp", { clear = true }),
    callback = function(args)
      setup_fn(args.buf)
    end,
  })
end

--- Automatically starts LSP for open and future buffers.
---@param server_names string[]
function M.auto_attach_lsp(server_names)
  local function try_lsp_attach(bufnr)
    local ft = vim.bo[bufnr].filetype
    if not ft or ft == "" then return end

    for _, name in ipairs(server_names) do
      local config = vim.lsp.get_config(name)
      if config and vim.tbl_contains(config.filetypes or {}, ft) then
        vim.lsp.start(config)
      end
    end
  end

  -- Attach LSP to all current buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      try_lsp_attach(bufnr)
    end
  end

  -- Attach LSP on future file reads
  vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(args)
      try_lsp_attach(args.buf)
    end,
  })
end

--- Entry point to set up all autocmds.
---@param server_names string[]
function M.setup(server_names)
  M.log_on_attach()
  M.setup_keymaps(require("config.lsp.keymap").setup)
  M.auto_attach_lsp(server_names)
end

return M
