-- SPDX-License-Identifier: MIT
-- tmux integration: nvim-tmux-navigation + vim-tpipeline (only inside tmux).

require('utils.lazy').add({
  src = 'https://github.com/alexghergh/nvim-tmux-navigation',
  deps = {
    'https://github.com/vimpostor/vim-tpipeline',
  },
  cond = function() return vim.env.TMUX ~= nil end,
  init = function()
    vim.g.tpipeline_autoembed = 0
    vim.o.laststatus = 0 -- hide nvim statusline immediately; tpipeline pipes it to tmux
  end,
  config = function()
    require('nvim-tmux-navigation').setup({
      disable_when_zoomed = true,
    })
  end,
})
