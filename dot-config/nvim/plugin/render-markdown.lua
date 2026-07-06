-- SPDX-License-Identifier: MIT
-- render-markdown.nvim: enhanced markdown rendering (loaded on FileType markdown).

require('utils.lazy').add({
  src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  ft = 'markdown',
  opts = {
    anti_conceal = { enabled = false },
    file_types = { 'markdown' },
    html = { comment = { conceal = true } },
    code = {
      style = 'full',
      sign = true,
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
    checkbox = {
      unchecked = { icon = '󰄱 ' },
      checked = { icon = '󰄵 ' },
      custom = {
        todo = { raw = '[-]', rendered = '󰡖 ', highlight = 'RenderMarkdownTodo' },
        in_progress = { raw = '[/]', rendered = '󰦖 ', highlight = 'RenderMarkdownWarn' },
        waiting = { raw = '[>]', rendered = '󰅐 ', highlight = 'RenderMarkdownHint' },
      },
    },
  },
})
