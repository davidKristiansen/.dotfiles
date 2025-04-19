-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "codecompanion" },
    opts = {
      html = { comment = { conceal = true } },
      code = {
        -- disable_background = { 'diff' },
        style = "full",
        disable_background = true,
        width = "block",
        position = "right",
        border = "none",
        highlight = "RenderMarkdownCode",
      },
      heading = {
        --   enabled = true,
        --   render_modes = false,
        --   sign = true,
        position = "inline",
        icons = { "󰬺. ", "󰬻. ", "󰬼. ", "󰬽. ", "󰬾. ", "󰬿. " },
        width = "block",
        backgrounds = {
          "none",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
        --   position = 'overlay',
        --   signs = { '󰫎 ' },
        --   width = 'full',
        --   left_margin = 0,
        --   left_pad = 0,
        --   right_pad = 0,
        --   min_width = 0,
        --   border = false,
        --   border_virtual = false,
        --   border_prefix = false,
        --   above = '▄',
        --   below = '▀',
        --   backgrounds = {
        --   },
        --   foregrounds = {
        --     'RenderMarkdownH1',
        --   },
        --   custom = {},
      },
    },
  },
}
