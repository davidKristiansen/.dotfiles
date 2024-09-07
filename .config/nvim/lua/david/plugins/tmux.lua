return {
  {
    'mrjones2014/smart-splits.nvim',
    dependencies = {
      "kwkarlwang/bufresize.nvim",
    },
    lazy = false,
    opts = {
      ignored_filetypes = { 'neo-tree' },
      resize_mode = {
        -- hooks = {
        --   on_leave = require("bufresize").register
        -- }
      },
    }
  },
  {
    "kwkarlwang/bufresize.nvim",
    event = { "VimResized" },
    opts = {},
  },
  {
    'mrjones2014/legendary.nvim',
    -- since legendary.nvim handles all your keymaps/commands,
    -- its recommended to load legendary.nvim before other plugins
    priority = 10000,
    lazy = false,
    -- sqlite is only needed if you want to use frecency sorting
    dependencies = { 'kkharji/sqlite.lua' },
    opts = {
      extensions = {
        which_key = {
          auto_register = true,
        },
        -- default settings shown below:
        smart_splits = {
          directions = { 'h', 'j', 'k', 'l' },
          mods = {
            -- for moving cursor between windows
            move = '<C>',
            -- for resizing windows
            resize = '<M>',
            -- for swapping window buffers
            swap = false, -- false disables creating a binding
          },
        },
      }
    }
  },
  -- {
  --   "alexghergh/nvim-tmux-navigation",
  --   opts = {
  --     disable_when_zoomed = true
  --   },
  --   keys = {
  --     { "<C-h>",     "<cmd>NvimTmuxNavigateLeft<CR>",        desc = "Navigate left" },
  --     { "<C-j>",     "<cmd>NvimTmuxNavigateDown<CR>",        desc = "Navigate down" },
  --     { "<C-k>",     "<cmd>NvimTmuxNavigateUp<CR>",          desc = "Navigate up" },
  --     { "<C-l>",     "<cmd>NvimTmuxNavigateRight<CR>",       desc = "Navigate right" },
  --     { "<C->",      "<cmd>NvimTmuxNavigateLastActive<CR>",  desc = "Navigate last active" },
  --     { "<C-Space>", "<cmd>NvimTmuxNavigateNext<CR>",        desc = "Navigate next" }
  --   }
  -- }
}
