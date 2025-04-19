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
  --   lazy = false,
  --   config = function()
  --     -- -- vim.g.tpipeline_refreshcmd = "kitty @ set-tab-title Master test"
  --     -- -- vim.g.tpipeline_clearstl = 1
  --     -- -- vim.g.tpipeline_restore = 1
  --     -- vim.g.tpipeline_autoembed = 1
  --     -- vim.g.tpipeline_clearstl = 1
  --     -- -- vim.o.fcs = "stlnc:─,stl:─,vert:│"
  --     -- -- vim.opt.fillchars:append({ eob = " " })
  --   end
  -- }
}
