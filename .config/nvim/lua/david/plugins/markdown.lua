return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ft = { "markdown" },
    opts = {
      -- preset = "none",
      code = {
        -- disable_background = { 'diff' },
        style = "full",
        disable_background = false,
        width = 'block',
        position = 'right'
      },
      heading = {
        backgrounds = {}
      },
      -- heading = {
      --   enabled = true,
      --   render_modes = false,
      --   sign = true,
      --   icons = { '󰉫 ', '󰉬 ', '󰉭 ', '󰉮 ', '󰉯 ', '󰉰 ' },
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
      -- },
      overrides = {
        -- Markdown Header Background Overrides with Foreground Colors
        ['@markup.heading.1.markdown'] = { fg = '#fb4934', bg = '', bold = true },
        ['@markup.heading.2.markdown'] = { fg = '#fabd2f', bg = '', bold = true },
        ['@markup.heading.3.markdown'] = { fg = '#b8bb26', bg = '', bold = true },
        ['@markup.heading.4.markdown'] = { fg = '#8ec07c', bg = '', bold = true },
        ['@markup.heading.5.markdown'] = { fg = '#83a598', bg = '', bold = true },
        ['@markup.heading.6.markdown'] = { fg = '#d3869b', bg = '', bold = true },
      },
    },
  }
}
