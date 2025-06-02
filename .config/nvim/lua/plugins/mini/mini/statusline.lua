-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

-- Gruvbox-inspired colors for all modes
local gruvbox = require("gruvbox").palette
vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = gruvbox.dark0_hard, bg = gruvbox.bright_green, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { fg = gruvbox.dark0_hard, bg = gruvbox.bright_blue, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { fg = gruvbox.dark0_hard, bg = gruvbox.bright_orange, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { fg = gruvbox.dark0_hard, bg = gruvbox.neutral_red, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = gruvbox.dark0_hard, bg = gruvbox.bright_yellow, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { fg = gruvbox.dark0_hard, bg = gruvbox.neutral_purple, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { fg = gruvbox.gray, bg = gruvbox.dark2 })
vim.api.nvim_set_hl(0, "LualineRecording", { fg = gruvbox.neutral_red, bg = gruvbox.dark0_hard, bold = true })

vim.api.nvim_create_autocmd("RecordingEnter", {
  callback = function()
    vim.cmd("redrawstatus!")
    vim.defer_fn(function()
      vim.cmd("redrawstatus!")
    end, 100)
  end
})


return {
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git           = MiniStatusline.section_git({ trunc_width = 40 })
      local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
      local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
      local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
      local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
      local location      = MiniStatusline.section_location({ trunc_width = 75 })

      -- Macro indicator (shows when recording a macro)
      local macro         = ''
      local reg           = vim.fn.reg_recording()
      if reg ~= '' then
        macro = '%#LualineRecording#●%* ' .. reg
      end

      return MiniStatusline.combine_groups({
        { hl = mode_hl,                 strings = { mode, macro } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = {} },
        '%=',
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl,                  strings = { location } },
      })
    end,
    inactive = nil,
  },
  use_icons = true,
}
