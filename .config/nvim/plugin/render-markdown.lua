-- SPDX-License-Identifier: MIT
-- render-markdown.nvim: enhanced markdown rendering.
-- Loaded on FileType markdown or opencode_output.

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'opencode_output' },
  once = true,
  callback = function()
    vim.pack.add({
      { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
    }, { confirm = false })

    require('render-markdown').setup({
      anti_conceal = { enabled = false },
      file_types   = { 'markdown', 'opencode_output' },
      html         = { comment = { conceal = true } },
      code = {
        style     = 'full',
        sign      = true,
        width     = 'block',
        position  = 'none',
        border    = 'none',
        highlight = 'RenderMarkdownCode',
      },
      heading = {
        enable    = true,
        left_pad  = 1,
        right_pad = 1,
        width     = 'block',
        sign      = true,
        icons     = function(ctx)
          return table.concat(ctx.sections, '.') .. '. '
        end,
      },
    })

    -- Re-trigger FileType for the current buffer so render-markdown attaches
    vim.cmd('doautocmd FileType')
  end,
})
