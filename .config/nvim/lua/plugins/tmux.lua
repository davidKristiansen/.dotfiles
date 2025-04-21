-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  {
    "alexghergh/nvim-tmux-navigation",
    opts = {
      disable_when_zoomed = true
    },
    keys = {
      { "<C-h>",     "<cmd>NvimTmuxNavigateLeft<CR>",       desc = "Navigate left" },
      { "<C-j>",     "<cmd>NvimTmuxNavigateDown<CR>",       desc = "Navigate down" },
      { "<C-k>",     "<cmd>NvimTmuxNavigateUp<CR>",         desc = "Navigate up" },
      { "<C-l>",     "<cmd>NvimTmuxNavigateRight<CR>",      desc = "Navigate right" },
      { "<C->",      "<cmd>NvimTmuxNavigateLastActive<CR>", desc = "Navigate last active" },
      { "<C-Space>", "<cmd>NvimTmuxNavigateNext<CR>",       desc = "Navigate next" }
    }
  },
  -- {
  --   'vimpostor/vim-tpipeline',
  --   event = 'VeryLazy',
  --   init = function()
  --     vim.g.tpipeline_autoembed = 0
  --     vim.g.tpipeline_statusline = ''
  --   end,
  --   config = function()
  --     vim.cmd.hi { 'link', 'StatusLine', 'WinSeparator' }
  --     vim.g.tpipeline_statusline = ''
  --     vim.o.laststatus = 0
  --     vim.o.fillchars = 'stl:─,stlnc:─'
  --   end,
  --   cond = function()
  --     return vim.env.TMUX ~= nil
  --   end,
  -- },
}
