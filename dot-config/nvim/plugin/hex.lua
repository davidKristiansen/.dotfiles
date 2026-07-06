-- SPDX-License-Identifier: MIT
-- hex.nvim: hex editing via xxd (keymap-triggered, <leader>Tx).

require('utils.lazy').add({
  src = 'https://github.com/RaafatTurki/hex.nvim',
  config = function()
    require('hex').setup()
  end,
  keys = {
    -- Under the <leader>T toggles group (<leader>h is the start screen).
    {
      '<leader>Tx',
      function()
        require('hex').toggle()
      end,
      desc = 'Toggle hex view',
    },
  },
})
