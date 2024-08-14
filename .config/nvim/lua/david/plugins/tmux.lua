return {
  {
    "alexghergh/nvim-tmux-navigation",
    opts = {
      disable_when_zoomed = true
    },
    keys = {
      { "<C-h>",     "<cmd>NvimTmuxNavigateLeft<CR>",        desc = "Navigate left" },
      { "<C-j>",     "<cmd>NvimTmuxNavigateDown<CR>",        desc = "Navigate down" },
      { "<C-k>",     "<cmd>NvimTmuxNavigateUp<CR>",          desc = "Navigate up" },
      { "<C-l>",     "<cmd>NvimTmuxNavigateRight<CR>",       desc = "Navigate right" },
      { "<C->",      "<cmd>NvimTmuxNavigateLastActive<CR>",  desc = "Navigate last active" },
      { "<C-Space>", "<cmd>NvimTmuxNavigateNext<CR>",        desc = "Navigate next" }
    }
  }
}
