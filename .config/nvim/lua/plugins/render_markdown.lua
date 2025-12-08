-- SPDX-License-Identifier: MIT
-- lua/plugins/render_markdown.lua
-- Configuration wrapper for MeanderingProgrammer/render-markdown.nvim
-- Translates prior lazy.nvim style spec into this project's module pattern.

vim.pack.add({
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
}, { confirm = false })


require("render-markdown").setup({
  html = {
    comment = { conceal = true },
  },
  code = {
    -- style "full" enables full block rendering (borders / padding semantics internal to plugin)
    style = 'full',
    -- style = 'normal',
    sign = true,
    -- disable_background = true,
    width = 'block',
    position = 'none',
    border = 'none',
    highlight = 'RenderMarkdownCode',
  },
  heading = {
    enable = true,
    left_pad = 1,
    right_pad = 1,
    width = 'block',
    sign = true,
    icons = function(ctx)
      return table.concat(ctx.sections, '.') .. '. '
    end,
  },
  -- heading = {
  --   position = 'inline',
  --   icons = { '󰬺. ', '󰬻. ', '󰬼. ', '󰬽. ', '󰬾. ', '󰬿. ' },
  --   width = 'block',
  --   backgrounds = { 'none' },
  --   foregrounds = {
  --     'RenderMarkdownH1',
  --     'RenderMarkdownH2',
  --     'RenderMarkdownH3',
  --     'RenderMarkdownH4',
  --     'RenderMarkdownH5',
  --     'RenderMarkdownH6',
  --   },
  -- },
})
