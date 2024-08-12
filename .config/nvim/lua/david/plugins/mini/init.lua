return {
  {
    'echasnovski/mini.nvim',
    event   = "VeryLazy",
    version = false,
    config  = function()
      require('mini.ai').setup()
      require('mini.align').setup()
      require('mini.basics').setup()
      require('mini.bracketed').setup()
      require('mini.bufremove').setup()
      require('mini.cursorword').setup()
      require('mini.diff').setup()
      require('mini.extra').setup()
      -- require('mini.git').setup()
      require('mini.hipatterns').setup()
      require('mini.icons').setup()
      -- require('mini.indentscope').setup({
      --   symbol = '▏',
      --   options = { try_as_border = true },
      -- })
      require('mini.jump').setup()
      require('mini.jump2d').setup()
      require('mini.map').setup()
      require('mini.move').setup()
      require('mini.notify').setup({
        lsp_progress = {
          enable = false,
        }
      })
      require('mini.operators').setup()
      require('mini.splitjoin').setup()
    end,
  },
  {
    'echasnovski/mini.map',
    version = false,
    init    = function()
      local wk = require("which-key")
      wk.add({
        { "m", group = "map" },
      })
    end,
    keys    = {
      { '<Leader>mc', function() MiniMap.close() end,        desc = "Close" },
      { '<Leader>mf', function() MiniMap.toggle_focus() end, desc = "Toggle focus" },
      { '<Leader>mo', function() MiniMap.open() end,         desc = "Open" },
      { '<Leader>mr', function() MiniMap.refresh() end,      desc = "Refresh" },
      { '<Leader>ms', function() MiniMap.toggle_side() end,  desc = "Toggle side" },
      { '<Leader>mt', function() MiniMap.toggle() end,       desc = "Toggle" }
    }
  },
  {
    'echasnovski/mini.surround',
    event   = "VeryLazy",
    version = false,
    opts    = {
      mappings = {
        add            = 'gsa', -- Add surrounding in Normal and Visual modes
        delete         = 'gsd', -- Delete surrounding
        find           = 'gsf', -- Find surrounding (to the right)
        find_left      = 'gsF', -- Find surrounding (to the left)
        highlight      = 'gsh', -- Highlight surrounding
        replace        = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`

        suffix_last    = 'l',   -- Suffix to search with "prev" method
        suffix_next    = 'n',   -- Suffix to search with "next" method
      },
    },
    init    = function()
      local wk = require("which-key")
      wk.add({
        { "gs", group = "surround" },
      })
    end,
    -- keys = {
    --   {'gs', function () require("mini.surround") end, mode = {'n', 'v'}}
    -- }
  }
}
