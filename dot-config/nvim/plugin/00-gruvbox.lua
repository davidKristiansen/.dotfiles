-- SPDX-License-Identifier: MIT
-- Colorscheme: must load first (00- prefix, eager).

require('utils.lazy').add({
  src = 'https://github.com/sainnhe/gruvbox-material',
  lazy = false,
  init = function()
    vim.g.gruvbox_material_enable_italic = true
    vim.g.gruvbox_material_enable_bold = true
    vim.g.gruvbox_material_background = 'hard'
    vim.g.gruvbox_material_foreground = 'original'
    vim.g.gruvbox_material_better_performance = 1
    vim.g.gruvbox_material_transparent_background = 2
    vim.g.gruvbox_material_sign_column_background = 'none'
    vim.g.gruvbox_material_ui_contrast = 'high'
    vim.g.gruvbox_material_float_style = 'blend'
  end,
  config = function()
    local function overrides()
      local Pmenu = vim.api.nvim_get_hl(0, { name = 'Pmenu' })
      local PmenuSel = vim.api.nvim_get_hl(0, { name = 'PmenuSel' })

      vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { bg = 'NONE', fg = Pmenu.fg })
      vim.api.nvim_set_hl(
        0,
        'BlinkCmpMenuSelection',
        { bg = PmenuSel.bg, fg = PmenuSel.fg, bold = true }
      )
      vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { bg = 'NONE', fg = Pmenu.fg })

      -- Gitsigns links its word-level *Inline groups to TermCursor, which here
      -- is bg=<fg color> with no fg -> beige-on-beige, unreadable in the
      -- preview_hunk float (<leader>gh). Redefine as a bright diff-color bg
      -- with a dark fg, matching how gruvbox keeps DiffText legible. Defined
      -- before gitsigns' scheduled setup(), so gitsigns leaves them alone.
      local function fg(group)
        return vim.api.nvim_get_hl(0, { name = group }).fg
      end
      local dark = '#1d2021'
      vim.api.nvim_set_hl(0, 'GitSignsAddInline', { bg = fg('Green'), fg = dark })
      vim.api.nvim_set_hl(0, 'GitSignsChangeInline', { bg = fg('Blue'), fg = dark })
      vim.api.nvim_set_hl(0, 'GitSignsDeleteInline', { bg = fg('Red'), fg = dark })
    end

    vim.cmd.colorscheme('gruvbox-material')
    overrides()
    -- Reapply on any colorscheme reload; registered here (eager) before
    -- gitsigns' own ColorScheme handler, so ours sets the groups first.
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('GruvboxOverrides', { clear = true }),
      callback = overrides,
    })
  end,
})
