-- SPDX-License-Identifier: MIT
-- lua/plugins/render_markdown.lua
-- Configuration wrapper for MeanderingProgrammer/render-markdown.nvim
-- Translates prior lazy.nvim style spec into this project's module pattern.

local M = {}

function M.setup()
  local ok, rm = pcall(require, 'render-markdown')
  if not ok then return end

  rm.setup({
    html = {
      comment = { conceal = true },
    },
    code = {
      -- style "full" enables full block rendering (borders / padding semantics internal to plugin)
      style = 'full',
      disable_background = true, -- previously disable_background = true (overrides style segment background)
      width = 'block',
      position = 'left',
      border = 'none',
      highlight = 'RenderMarkdownCode',
    },
    heading = {
      position = 'inline',
      icons = { '󰬺. ', '󰬻. ', '󰬼. ', '󰬽. ', '󰬾. ', '󰬿. ' },
      width = 'block',
      backgrounds = { 'none' },
      foregrounds = {
        'RenderMarkdownH1',
        'RenderMarkdownH2',
        'RenderMarkdownH3',
        'RenderMarkdownH4',
        'RenderMarkdownH5',
        'RenderMarkdownH6',
      },
    },
  })
end

return M

