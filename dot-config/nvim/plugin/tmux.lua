-- SPDX-License-Identifier: MIT
-- tmux integration: nvim-tmux-navigation + vim-tpipeline (only inside tmux).
-- Owns the <C-h/j/k/l> pane-navigation maps; outside tmux they fall back to
-- plain window navigation so the keys behave the same everywhere.

if vim.env.TMUX == nil then
  local map = vim.keymap.set
  map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
  map('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window' })
  map('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window' })
  map('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })
  return
end

require('utils.lazy').add({
  src = 'https://github.com/alexghergh/nvim-tmux-navigation',
  deps = {
    'https://github.com/vimpostor/vim-tpipeline',
  },
  init = function()
    vim.g.tpipeline_autoembed = 0
    vim.o.laststatus = 0 -- hide nvim statusline immediately; tpipeline pipes it to tmux
  end,
  config = function()
    require('nvim-tmux-navigation').setup({
      disable_when_zoomed = true,
    })

    local map = vim.keymap.set
    map('n', '<C-h>', '<cmd>NvimTmuxNavigateLeft<CR>', { desc = 'Navigate left pane' })
    map('n', '<C-j>', '<cmd>NvimTmuxNavigateDown<CR>', { desc = 'Navigate down pane' })
    map('n', '<C-k>', '<cmd>NvimTmuxNavigateUp<CR>', { desc = 'Navigate up pane' })
    map('n', '<C-l>', '<cmd>NvimTmuxNavigateRight<CR>', { desc = 'Navigate right pane' })
    map(
      'n',
      '<C-\\>',
      '<cmd>NvimTmuxNavigateLastActive<CR>',
      { desc = 'Navigate last active pane' }
    )
    map('n', '<C-Space>', '<cmd>NvimTmuxNavigateNext<CR>', { desc = 'Navigate next pane' })
  end,
})
