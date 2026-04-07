-- SPDX-License-Identifier: MIT
-- tmux integration: nvim-tmux-navigation + vim-tpipeline.

if not vim.env.TMUX then return end

vim.g.tpipeline_autoembed = 0
vim.o.laststatus = 0   -- hide nvim statusline immediately; tpipeline pipes it to tmux

vim.schedule(function()
  vim.pack.add({
    { src = 'https://github.com/alexghergh/nvim-tmux-navigation' },
    { src = 'https://github.com/vimpostor/vim-tpipeline' },
  }, { confirm = false })

  require('nvim-tmux-navigation').setup({
    disable_when_zoomed = true,
  })
end)
