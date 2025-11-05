-- SPDX-License-Identifier: MIT
-- lua/plugins/dial.lua
-- Plugin configuration for dial.nvim: augend groups + keymaps
-- The previous version of this file had malformed Lua (dangling `keys =` table
-- outside any plugin spec). This rewrite normalizes structure and applies
-- keymaps during setup following existing project conventions.

vim.pack.add({
  { src = "https://github.com/monaqa/dial.nvim" },
}, { confirm = false })

local augend = require 'dial.augend'
-- Register augend groups (values to increment / decrement through)
require('dial.config').augends:register_group({
  -- Default augends used when no group name is specified
  default = {
    augend.hexcolor.new({ case = 'lower' }),
    augend.integer.alias.decimal_int,
    augend.integer.alias.hex,
    augend.date.alias['%Y/%m/%d'],
    augend.constant.alias.bool,
    augend.semver.alias.semver,
    augend.constant.new({ elements = { 'true', 'false' }, word = false, cyclic = true }),
    augend.constant.new({ elements = { 'True', 'False' }, word = false, cyclic = true }),
    augend.constant.new({
      elements = { 'and', 'or' },
      word = true,   -- if false, "sand" would become "sor", etc.
      cyclic = true, -- "or" increments to "and".
    }),
    augend.constant.new({ elements = { '&&', '||' }, word = false, cyclic = true }),
    augend.constant.new({ elements = { 'on', 'off' }, word = false, cyclic = true }),
    augend.constant.new({
      elements = { 'debug', 'info', 'warning', 'error', 'critical' },
      word = false,
      cyclic = false,
    }),
    augend.constant.new({
      elements = { '######', '#####', '####', '###', '##', '#' },
      word = false,
      cyclic = false,
    }),
  },

  -- Example alternate group (can be invoked manually if needed)
  mygroup = {
    augend.integer.alias.decimal,
    augend.constant.alias.bool,    -- boolean value (true <-> false)
    augend.date.alias['%m/%d/%Y'], -- date (e.g. 02/19/2022)
  },
})

-- Keymaps: replicate canonical dial mappings with descriptions for which-key
local map = vim.keymap.set
local opts_n = { silent = true }
local opts_v = { silent = true }

-- Normal mode increment / decrement
map('n', '<C-a>', function() require('dial.map').manipulate('increment', 'normal') end,
  vim.tbl_extend('force', opts_n, { desc = 'Increment' }))
map('n', '<C-x>', function() require('dial.map').manipulate('decrement', 'normal') end,
  vim.tbl_extend('force', opts_n, { desc = 'Decrement' }))

-- Normal mode sequential (spans over numbers in line)
map('n', 'g<C-a>', function() require('dial.map').manipulate('increment', 'gnormal') end,
  vim.tbl_extend('force', opts_n, { desc = 'Increment sequential' }))
map('n', 'g<C-x>', function() require('dial.map').manipulate('decrement', 'gnormal') end,
  vim.tbl_extend('force', opts_n, { desc = 'Decrement sequential' }))

-- Visual mode increment / decrement
map('v', '<C-a>', function() require('dial.map').manipulate('increment', 'visual') end,
  vim.tbl_extend('force', opts_v, { desc = 'Increment' }))
map('v', '<C-x>', function() require('dial.map').manipulate('decrement', 'visual') end,
  vim.tbl_extend('force', opts_v, { desc = 'Decrement' }))

-- Visual mode sequential
map('v', 'g<C-a>', function() require('dial.map').manipulate('increment', 'gvisual') end,
  vim.tbl_extend('force', opts_v, { desc = 'Increment sequential' }))
map('v', 'g<C-x>', function() require('dial.map').manipulate('decrement', 'gvisual') end,
  vim.tbl_extend('force', opts_v, { desc = 'Decrement sequential' }))

-- Alternative leader-based mappings (useful when <C-a>/<C-x> are intercepted by terminal or tmux)
-- map('n', '<leader>+', function() require('dial.map').manipulate('increment', 'normal') end, vim.tbl_extend('force', opts_n, { desc = 'Increment (dial)' }))
-- map('n', '<leader>-', function() require('dial.map').manipulate('decrement', 'normal') end, vim.tbl_extend('force', opts_n, { desc = 'Decrement (dial)' }))
-- map('v', '<leader>+', function() require('dial.map').manipulate('increment', 'visual') end, vim.tbl_extend('force', opts_v, { desc = 'Increment (dial)' }))
-- map('v', '<leader>-', function() require('dial.map').manipulate('decrement', 'visual') end, vim.tbl_extend('force', opts_v, { desc = 'Decrement (dial)' }))

-- Debug helper: shows the active augend group for the current buffer
vim.api.nvim_create_user_command('DialDebug', function()
  local group = vim.b.dial_config_group or 'default'
  print('[dial] active group: ' .. group)
end, { desc = 'Dial: show active augend group' })
