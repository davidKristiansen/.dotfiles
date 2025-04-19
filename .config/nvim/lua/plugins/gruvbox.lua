-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "ellisonleao/gruvbox.nvim",
  version = false,
  lazy = false,
  priority = 1000,
  -- opts table is passed to require("gruvbox").setup()
  opts = {
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
      strings = true,
      comments = true,
      operators = false,
      folds = true,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true,
    contrast = "hard", -- can be "hard", "soft", or empty string
    palette_overrides = {},
    overrides = {
      -- ColorColumn = { bg = "none" },
      SignColumn = { bg = "none" },
      WinBar = { bg = "none" },
      WinBarNC = { bg = "none" },
      TabLineFill = { bg = "none" },
      TabLine = { bg = "none" },
      TabLineSel = { bg = "none" },
      StatusLine = { bg = "none" },
      StatusLineNC = { bg = "none" },
      CursorLine = { bg = "none" },
      Comments = {
        undercurl = true,
      },
    },
    dim_inactive = false,
    transparent_mode = false,
  },
  -- init is run early (before plugin loads)
  init = function()
    local palette = require("gruvbox").palette

    -- Global colorscheme setup
    vim.cmd([[
    set background=dark
    colorscheme gruvbox
    highlight! link StatusLine Normal
    highlight! link StatusLineNC NormalNC
    ]])

    vim.api.nvim_set_hl(0, "NormalFloat", {
      bg = "NONE",
      fg = palette.light1,
      blend = 0
    })

    -- Markdown-specific highlights
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = "#fb4934", bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#fabd2f", bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = "#b8bb26", bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = "#8ec07c", bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = "#83a598", bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { fg = "#d3869b", bg = "", bold = true })

        vim.api.nvim_set_hl(0, "DiffAdd", { fg = "", bg = "" })
        vim.api.nvim_set_hl(0, "DiffChange", { fg = "", bg = "" })
        vim.api.nvim_set_hl(0, "DiffDelete", { fg = "", bg = "" })
      end,
    })

    vim.api.nvim_set_hl(0, "StatusLine", { bg = palette.dark0, fg = palette.light1 })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = palette.dark0, fg = palette.gray })
  end,
}
