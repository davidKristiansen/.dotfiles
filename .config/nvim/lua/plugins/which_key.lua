-- SPDX-License-Identifier: MIT
-- lua/plugins/which_key.lua
local M = {}

function M.setup()
  local ok, wk = pcall(require, 'which-key')
  if not ok then return end

  wk.setup({
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = false },
      presets = { operators = false, motions = false, text_objects = false, windows = true, nav = true, z = true, g = true },
    },
    win = { border = 'rounded' }, -- migrated from deprecated `window`
    layout = { align = 'center' },
    show_help = false,
  })

  -- New spec-style group registration (replaces legacy wk.register table form)
  -- Only high-level leader groups; concrete mappings live in keymaps.lua
  wk.add({
    { '<leader>a', group = 'ai' },
    { '<leader>c', group = 'code' },
    { '<leader>s', group = 'search' },
  })
end

return M

