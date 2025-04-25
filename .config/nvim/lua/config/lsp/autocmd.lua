-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

---@module "config.lsp.autostart"
local M = {}
local lsp = vim.lsp

-- Create a single augroup for all LSP hooks
local augroup = vim.api.nvim_create_augroup("user.lsp", { clear = true })

--- Logs when any LSP client attaches to a buffer.
---@return nil
function M.log_on_attach()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
      local client = lsp.get_client_by_id(args.data.client_id)
      vim.notify(("[LSP] Attached %s → buffer %d"):format(
        client and client.name or "unknown",
        args.buf
      ))
    end,
  })
end

--- Sets up keymaps for LSP when a client attaches.
--- Your `setup_fn` should use buffer-local mappings (e.g., vim.keymap.set with {buffer = bufnr}).
---@param setup_fn fun(bufnr: integer)
---@return nil
function M.setup_keymaps(setup_fn)
  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
      setup_fn(args.buf)
    end,
  })
end

--- Enables LSP servers to automatically start with matching buffers.
--- Uses the built-in vim.lsp.enable API (since Neovim 0.11).
---@param server_names string|string[] Names of LSP servers to enable.
---@return nil
function M.auto_attach_lsp(server_names)
  lsp.enable(server_names)
end

--- Entry point to set up all autocmds and enable servers.
---@param server_names string|string[] Names of LSP servers to enable.
---@return nil
function M.setup(server_names)
  -- Setup autoformatting
  require("config.lsp.format")

  -- Logging on attach
  M.log_on_attach()

  -- LSP keymaps (remember to use buffer-local mappings in your setup)
  M.setup_keymaps(require("config.lsp.keymap").setup)

  -- Automatically enable and start servers
  M.auto_attach_lsp(server_names)
end

return M
