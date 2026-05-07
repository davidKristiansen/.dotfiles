-- SPDX-License-Identifier: MIT
-- which-key.nvim: keymap discovery.

vim.pack.add({
  { src = 'https://github.com/folke/which-key.nvim' },
}, { confirm = false })

vim.o.timeout    = true
vim.o.timeoutlen = 400

local wk = require('which-key')

wk.setup({ preset = 'helix' })

wk.add({
  { '<leader>c', group = 'code' },
  { '<leader>d', group = 'debug' },
  { '<leader>e', group = 'explorer' },
  { '<leader>f', group = 'find' },
  { '<leader>g', group = 'git' },
  { '<leader>n', group = 'notes' },
  { '<leader>o', group = 'overseer' },
  { '<leader>a', group = 'ai' },
  { '<leader>p', group = 'pi' },
  { '<leader>t', group = 'tests' },
  { '<leader>T', group = 'toggles' },
  { '<leader>w', group = 'worktree' },
  { ']',         group = 'next ->' },
  { '[',         group = 'prev <-' },
  { 'g',         group = 'goto' },
  { 'z',         group = 'folds/scroll' },
}, { mode = { 'n', 'v', 'o' } })

wk.add({
  { 'gd', group = 'goto' },
}, { mode = { 'n' } })
