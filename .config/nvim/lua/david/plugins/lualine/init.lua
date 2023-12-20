return {
{
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      "SmiteshP/nvim-navic",
    },
    opts = {
      options = {
        theme = require("david.plugins.lualine.theme"),
        section_separators = { left = '', right = '' },
        component_separators = { left = '╲', right = '╱ ' },
        disabled_filetypes = {
          statusline = {},
          winbar = { "neo-tree" },
        },
      },
      extensions = {
        'quickfix',
        'neo-tree',
        'lazy'
      },
      winbar = {
        lualine_a = { { 'filename', path = 1 } },
        lualine_b = {
          {
            "navic",
            color_correction = nil,
            navic_opts = nil
          }
        }
      },
      inactive_winbar = {
        lualine_a = { { 'filename', path = 1 } }
      }
    }
  },
  {
    "SmiteshP/nvim-navic",
    opts = {
      lsp = {
        auto_attach = true,
      },
      click = true,
      highlight = true,
    }
  }
}
