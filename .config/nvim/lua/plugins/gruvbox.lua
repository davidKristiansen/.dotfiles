-- lua/plugins/gruvbox.lua
-- SPDX-License-Identifier: MIT


local M = {}

function M.setup()
  vim.g.gruvbox_material_enable_italic = true
  vim.g.gruvbox_material_enable_bold = true
  vim.g.gruvbox_material_background = "hard"
  vim.g.gruvbox_material_foreground = "original"
  vim.g.gruvbox_material_better_performance = 1
  vim.g.gruvbox_material_transparent_background = 2
  vim.g.gruvbox_material_sign_column_background = "none"
  vim.g.gruvbox_material_ui_contrast = "high"
  vim.g.gruvbox_material_float_style = "none"

  vim.cmd.colorscheme("gruvbox-material")

  local Pmenu       = vim.api.nvim_get_hl(0, { name = "Pmenu" })
  local PmenuSel    = vim.api.nvim_get_hl(0, { name = "PmenuSel" })
  local FloatBorder = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
  local NormalFloat = vim.api.nvim_get_hl(0, { name = "NormalFloat" })

  -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", fg = Pmenu.fg })

  vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = 'NONE', fg = Pmenu.fg })
  vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = PmenuSel.bg, fg = PmenuSel.fg, bold = true })
  vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "NONE", fg = Pmenu.fg })

  -- vim.api.nvim_set_hl(0, "winborder", { bg = "NONE", fg = Pmenu.fg })
end

return M
