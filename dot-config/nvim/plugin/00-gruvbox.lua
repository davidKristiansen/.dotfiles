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
    vim.cmd.colorscheme('gruvbox-material')

    local Pmenu = vim.api.nvim_get_hl(0, { name = 'Pmenu' })
    local PmenuSel = vim.api.nvim_get_hl(0, { name = 'PmenuSel' })

    vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { bg = 'NONE', fg = Pmenu.fg })
    vim.api.nvim_set_hl(
      0,
      'BlinkCmpMenuSelection',
      { bg = PmenuSel.bg, fg = PmenuSel.fg, bold = true }
    )
    vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { bg = 'NONE', fg = Pmenu.fg })
  end,
})
