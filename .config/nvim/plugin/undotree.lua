-- SPDX-License-Identifier: MIT
-- undotree: visual undo history (built-in Neovim 0.12+).
-- Loaded on keymap press (<leader>u).

vim.keymap.set('n', '<leader>u', function()
  vim.cmd('packadd nvim.undotree')
  require('undotree').open()
end, { desc = 'Undotree' })
