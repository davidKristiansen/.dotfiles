-- SPDX-License-Identifier: MIT
-- Single source of truth for all buffer-local LSP keymaps.

local fixall = require('core.lsp.fix_all')
local format = require('core.lsp.format')

local M = {}

--- Declarative keymap definitions.
--- Each entry: { mode, lhs, rhs, desc }
--- `desc` is auto-prefixed with "LSP: " unless it starts with a category.
---@param bufnr integer
---@return table[]
local function keymaps(bufnr)
  local picker = function(name)
    return function()
      require('utils.picker')[name]()
    end
  end

  return {
    -- Navigation
    { 'n', 'gd', picker('lsp_definitions'), 'Go to Definition' },
    { 'n', 'grr', picker('lsp_references'), 'List References' },
    { 'n', 'gri', picker('lsp_implementations'), 'Go to Implementation' },
    { 'n', 'grt', picker('lsp_type_definitions'), 'Go to Type Definition' },
    { 'n', 'gl', picker('diagnostics'), 'Line Diagnostics' },
    { 'n', 'gD', vim.lsp.buf.declaration, 'Go to Declaration' },
    {
      'n',
      'gvD',
      function()
        vim.lsp.buf.declaration({ jump_to_location_opts = { command = 'vsplit' } })
      end,
      'Go to Declaration (Vertical Split)',
    },
    { 'n', 'grn', vim.lsp.buf.rename, 'Rename' },

    -- Code actions
    { { 'n', 'x' }, 'gra', vim.lsp.buf.code_action, 'Code Actions' },
    { { 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code Action' },
    {
      'n',
      '<leader>cA',
      function()
        local applied = fixall.run(bufnr)
        vim.notify(applied and 'FixAll applied' or 'No FixAll actions')
      end,
      'Fix All (source.fixAll)',
    },

    -- Formatting
    {
      'n',
      '<leader>cf',
      function()
        format.changed(bufnr)
      end,
      'Format Changed Hunks',
    },
    { 'x', '<leader>cf', format.selection, 'Format Selection' },
    {
      'n',
      '<leader>cF',
      function()
        format.buffer(bufnr)
      end,
      'Format Buffer',
    },
    { 'n', '<leader>cl', format.line, 'Format Line' },

    -- Toggles
    {
      'n',
      '<leader>Tf',
      function()
        format.toggle_on_save_buffer(bufnr)
      end,
      'Toggle: Format on save (buffer)',
    },
    { 'n', '<leader>TF', format.toggle_on_save_global, 'Toggle: Format on save (global)' },
    {
      'n',
      '<leader>Th',
      function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
        vim.notify(('Inlay hints: %s'):format(enabled and 'OFF' or 'ON'))
      end,
      'Toggle: Inlay hints (buffer)',
    },
    {
      'n',
      '<leader>Ti',
      function()
        local enabled = not vim.lsp.inline_completion.is_enabled()
        vim.lsp.inline_completion.enable(enabled)
        vim.notify(('Inline completion: %s'):format(enabled and 'ON' or 'OFF'))
      end,
      'Toggle: Inline completion (global)',
    },
    {
      'n',
      '<leader>To',
      function()
        -- No is_enabled() for on-type formatting; track state ourselves.
        local new_state = not (vim.b[bufnr].on_type_formatting_enabled or false)
        vim.b[bufnr].on_type_formatting_enabled = new_state
        vim.lsp.on_type_formatting.enable(new_state, { bufnr = bufnr })
        vim.notify(('On-type formatting: %s'):format(new_state and 'ON' or 'OFF'))
      end,
      'Toggle: On-type formatting (buffer)',
    },

    -- Documentation
    { 'n', 'K', vim.lsp.buf.hover, 'Hover Documentation' },
    { 'i', '<C-k>', vim.lsp.buf.signature_help, 'Signature Help' },

    -- Diagnostics
    {
      'n',
      '[d',
      function()
        vim.diagnostic.jump({ count = -1 })
        vim.defer_fn(function()
          vim.diagnostic.open_float(nil, { focus = false })
        end, 50)
      end,
      'Previous Diagnostic',
    },
    {
      'n',
      ']d',
      function()
        vim.diagnostic.jump({ count = 1 })
        vim.defer_fn(function()
          vim.diagnostic.open_float(nil, { focus = false })
        end, 50)
      end,
      'Next Diagnostic',
    },
  }
end

function M.setup(bufnr)
  for _, km in ipairs(keymaps(bufnr)) do
    local mode, lhs, rhs, desc = km[1], km[2], km[3], km[4]
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end
end

return M
