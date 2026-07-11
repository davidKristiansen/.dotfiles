-- lua/core/lsp/init.lua
-- SPDX-License-Identifier: MIT
-- Single owner of all LSP wiring.
--
--   * Servers: lsp/*.lua is the single source of truth. Every file there is
--     enabled below; plugin/mason.lua reads the same list for installation.
--     Adding a server = adding one lsp/<name>.lua file.
--   * One LspAttach autocmd → core.lsp.on_attach (keymaps, inlay hints, …).
--   * Saving formats only git-changed hunks — see core.lsp.format.
--   * FixAll is manual-only (<leader>cA / :LspFixAll): it can be destructive
--     (e.g. removing "unused" imports/vars) and must never run on save.

local M = {}

-- Global toggles (keymaps under <leader>T).
vim.g.format_on_save = true -- hunk-scoped, so safe for third-party code
vim.g.inlay_hints_enabled = false
vim.g.on_type_formatting_enabled = false

--- Server names derived from lsp/*.lua.
---@return string[]
function M.servers()
  local names = {}
  for name, kind in vim.fs.dir(vim.fn.stdpath('config') .. '/lsp') do
    if kind == 'file' and name:sub(-4) == '.lua' then
      names[#names + 1] = name:sub(1, -5)
    end
  end
  table.sort(names)
  return names
end

-- Advertise file-operation capabilities (rename/create/delete notifications)
-- to every server. This mirrors lsp-file-operations default_capabilities()
-- statically, so servers started before neo-tree loads still get them; the
-- plugin itself (the event-hooking half) loads with neo-tree.
vim.lsp.config('*', {
  capabilities = {
    workspace = {
      fileOperations = {
        willRename = true,
        didRename = true,
        willCreate = true,
        didCreate = true,
        willDelete = true,
        didDelete = true,
      },
    },
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = require('core.lsp.on_attach'),
})

require('core.lsp.format').setup()

vim.api.nvim_create_user_command('LspFixAll', function()
  local applied = require('core.lsp.fix_all').run()
  vim.notify(applied and 'FixAll applied' or 'No FixAll actions')
end, { desc = 'LSP: fix all (Ruff/typos-lsp/etc.) — manual only' })

vim.lsp.enable(M.servers())

return M
