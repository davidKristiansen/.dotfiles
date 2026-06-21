-- SPDX-License-Identifier: MIT
-- dial.nvim: increment/decrement augends + keymaps (loaded on next tick).

require('utils.lazy').add({
  src = 'https://github.com/monaqa/dial.nvim',
  config = function()
    local augend = require('dial.augend')

    require('dial.config').augends:register_group({
      default = {
        augend.hexcolor.new({ case = 'lower' }),
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.date.alias['%Y/%m/%d'],
        augend.constant.alias.bool,
        augend.semver.alias.semver,
        augend.constant.new({ elements = { 'true', 'false' }, word = false, cyclic = true }),
        augend.constant.new({ elements = { 'True', 'False' }, word = false, cyclic = true }),
        augend.constant.new({ elements = { 'and', 'or' }, word = true, cyclic = true }),
        augend.constant.new({ elements = { '&&', '||' }, word = false, cyclic = true }),
        augend.constant.new({ elements = { 'on', 'off' }, word = false, cyclic = true }),
        augend.constant.new({
          elements = { 'debug', 'info', 'warning', 'error', 'critical' },
          word = false, cyclic = false,
        }),
        augend.constant.new({
          elements = { '######', '#####', '####', '###', '##', '#' },
          word = false, cyclic = false,
        }),
        -- Markdown checkbox states: [ ] -> [-] -> [/] -> [>] -> [x] -> [ ]
        augend.constant.new({
          elements = { '[ ]', '[-]', '[/]', '[>]', '[x]' },
          word = false, cyclic = true,
        }),
      },
      mygroup = {
        augend.integer.alias.decimal,
        augend.constant.alias.bool,
        augend.date.alias['%m/%d/%Y'],
      },
    })

    local map = vim.keymap.set

    map('n', '<C-a>',  function() require('dial.map').manipulate('increment', 'normal') end,  { silent = true, desc = 'Increment' })
    map('n', '<C-x>',  function() require('dial.map').manipulate('decrement', 'normal') end,  { silent = true, desc = 'Decrement' })
    map('n', 'g<C-a>', function() require('dial.map').manipulate('increment', 'gnormal') end, { silent = true, desc = 'Increment sequential' })
    map('n', 'g<C-x>', function() require('dial.map').manipulate('decrement', 'gnormal') end, { silent = true, desc = 'Decrement sequential' })
    map('v', '<C-a>',  function() require('dial.map').manipulate('increment', 'visual') end,  { silent = true, desc = 'Increment' })
    map('v', '<C-x>',  function() require('dial.map').manipulate('decrement', 'visual') end,  { silent = true, desc = 'Decrement' })
    map('v', 'g<C-a>', function() require('dial.map').manipulate('increment', 'gvisual') end, { silent = true, desc = 'Increment sequential' })
    map('v', 'g<C-x>', function() require('dial.map').manipulate('decrement', 'gvisual') end, { silent = true, desc = 'Decrement sequential' })

    vim.api.nvim_create_user_command('DialDebug', function()
      local group = vim.b.dial_config_group or 'default'
      print('[dial] active group: ' .. group)
    end, { desc = 'Dial: show active augend group' })
  end,
})
