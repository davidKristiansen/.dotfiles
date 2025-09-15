-- SPDX-License-Identifier: MIT
-- lua/plugins/which_key.lua
local M = {}

function M.setup()
  local ok, wk = pcall(require, 'which-key')
  if not ok then return end

  wk.setup({
    preset = "helix",
    show_help = false,
    show_keys = false,
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    win = {
      border = 'rounded',
      padding = { 1, 2 },
      zindex = 1000,
    },
    layout = { align = 'center' },
  })

  -- New spec-style group registration (replaces legacy wk.register table form)
  -- Only high-level leader groups; concrete mappings live in keymaps.lua
  wk.add({
    { '<leader>a', group = 'ai' },
    { '<leader>c', group = 'code' },
    { '<leader>g', group = 'git' },
    { '<leader>s', group = 'search' },
  })
end

return M
