-- SPDX-License-Identifier: MIT
-- pi-nvim: bridge between the pi coding agent and Neovim (keymap-triggered, <leader>p*).

require('utils.lazy').add({
  src = 'https://github.com/carderne/pi-nvim',
  config = function()
    require('pi-nvim').setup()
  end,
  keys = {
    { '<leader>pp', '<Cmd>Pi<CR>', mode = { 'n', 'v' }, desc = 'Pi send dialog' },
    { '<leader>ps', '<Cmd>PiSend<CR>', desc = 'Pi send prompt' },
    { '<leader>pf', '<Cmd>PiSendFile<CR>', desc = 'Pi send file' },
    { '<leader>pv', '<Cmd>PiSendSelection<CR>', mode = 'v', desc = 'Pi send selection' },
    { '<leader>pb', '<Cmd>PiSendBuffer<CR>', desc = 'Pi send buffer' },
    { '<leader>pi', '<Cmd>PiPing<CR>', desc = 'Pi ping' },
    { '<leader>pS', '<Cmd>PiSessions<CR>', desc = 'Pi sessions' },
  },
})
