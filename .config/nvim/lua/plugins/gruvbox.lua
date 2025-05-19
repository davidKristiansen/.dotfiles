-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "ellisonleao/gruvbox.nvim",
  version = false,
  lazy = false,
  priority = 1000,
  config = function()
    local gruvbox = require("gruvbox")
    local palette = gruvbox.palette

    gruvbox.setup({
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
      contrast = "hard",
      palette_overrides = {},
      overrides = {
        -- Core Gruvbox tweaks
        NormalFloat = { bg = palette.dark0, fg = palette.light1 },
        WinSeparator = { bg = palette.dark0, fg = palette.dark0 },
        VertSplit = { bg = palette.dark0, fg = palette.light1 },
        FloatBorder = { bg = palette.dark0, fg = palette.dark2 },
        ColorColumn = { bg = palette.dark2 },
        SignColumn = { bg = palette.dark1 },
        WinBar = { bg = "none" },
        WinBarNC = { bg = "none" },
        TabLineFill = { bg = "none" },
        TabLine = { bg = "none" },
        TabLineSel = { bg = "none" },
        CursorLine = { bg = palette.dark0 },
        Comments = { undercurl = true },
        StatusLine = { bg = palette.dark0, fg = palette.light1 },
        StatusLineNC = { bg = palette.dark0, fg = palette.gray },

        -- nvim-cmp
        CmpItemAbbr = { bg = palette.dark0 },
        CmpItemAbbrMatch = { bg = palette.dark0 },
        CmpItemAbbrMatchFuzzy = { bg = palette.dark0 },
        CmpItemMenu = { bg = palette.dark0 },
        CmpItemKind = { bg = palette.dark0 },
        CmpBorder = { fg = palette.dark2, bg = palette.dark0 },

        -- BlinkCmp
        BlinkCmpMenu = { bg = palette.dark0 },
        BlinkCmpMenuBorder = { bg = palette.dark0, fg = palette.dark2 },
        BlinkCmpMenuSelection = { bg = palette.dark2 },
        BlinkCmpScrollBarThumb = { bg = palette.dark2 },
        BlinkCmpScrollBarGutter = { bg = palette.dark1 },
        BlinkCmpLabel = { bg = palette.dark0 },
        BlinkCmpLabelDeprecated = { fg = palette.gray, bg = palette.dark0, strikethrough = true },
        BlinkCmpLabelMatch = { bg = palette.dark0, bold = true },
        BlinkCmpLabelDetail = { fg = palette.light2, bg = palette.dark0 },
        BlinkCmpLabelDescription = { fg = palette.gray, bg = palette.dark0 },
        BlinkCmpKind = { fg = palette.bright_blue, bg = palette.dark0 },
        BlinkCmpSource = { fg = palette.gray, bg = palette.dark0 },
        BlinkCmpGhostText = { fg = palette.gray, bg = palette.dark0, italic = true },
        BlinkCmpDoc = { bg = palette.dark0 },
        BlinkCmpDocBorder = { fg = palette.dark2, bg = palette.dark0 },
        BlinkCmpDocSeparator = { fg = palette.dark2, bg = palette.dark0 },
        BlinkCmpDocCursorLine = { bg = palette.dark2 },
        BlinkCmpSignatureHelp = { bg = palette.dark0 },
        BlinkCmpSignatureHelpBorder = { fg = palette.dark2, bg = palette.dark0 },
        BlinkCmpSignatureHelpActiveParameter = { fg = palette.bright_yellow, bg = palette.dark0, underline = true },

        -- Noice
        NoiceCmdline = { bg = palette.dark0 },
        NoiceCmdlinePopup = { bg = palette.dark0 },
        NoiceCmdlinePopupBorder = { fg = palette.dark2, bg = palette.dark0 },
        NoiceCmdlinePopupBorderSearch = { fg = palette.dark2, bg = palette.dark0 },
        NoiceCmdlinePopupTitle = { fg = palette.dark2, bg = palette.dark0 },
        NoiceConfirm = { bg = palette.dark0 },
        NoiceConfirmBorder = { fg = palette.dark2, bg = palette.dark0 },
        NoicePopup = { bg = palette.dark0 },
        NoicePopupBorder = { fg = palette.dark2, bg = palette.dark0 },
        NoicePopupmenu = { bg = palette.dark0 },
        NoicePopupmenuBorder = { fg = palette.dark2, bg = palette.dark0 },
        NoiceSplit = { bg = palette.dark0 },
        NoiceSplitBorder = { fg = palette.dark2, bg = palette.dark0 },

        -- Snacks indent
        SnacksIndent = { fg = palette.dark0 },
        SnacksIndentScope = { fg = palette.dark1 },
        SnacksIndentChunk = { fg = palette.dark1 },

        SnacksDashboardHeader = { fg = palette.bright_yellow, bg = "NONE", bold = true },
        SnacksDashboardSection = { fg = palette.light1, bg = "NONE" },
        SnacksDashboardShortcut = { fg = palette.bright_blue, bg = "NONE", italic = true },
        SnacksDashboardFooter = { fg = palette.gray, bg = "NONE", italic = true },

        -- We don't need to highlight trailing whitespace
        MiniTrailspace = { bg = palette.dark0_hard },

        -- Tabline
        MiniTablineCurrent = { fg = palette.light0_hard, bg = palette.dark1, bold = true },
        MiniTablineVisible = { fg = palette.light0, bg = palette.dark0 },
        MiniTablineHidden = { fg = palette.gray, bg = palette.dark0 },
        MiniTablineModifiedCurrent = { fg = palette.light0, bg = palette.dark1, italic = true },
        MiniTablineModifiedVisible = { fg = palette.light0, bg = palette.dark0, italic = true },
        MiniTablineModifiedHidden = { fg = palette.light0, bg = palette.dark0, italic = true },
        MiniTablineFill = { fg = palette.dark1, bg = palette.dark0_hard },
        MiniTablineTabpagesection = { fg = palette.bright_green, bg = palette.dark2 },
        MiniTablineTrunc = { fg = palette.gray, bg = palette.dark0 },

        -- Avante
        -- AvanteTitle = { fg = palette.light0, bg = palette.bright_green, bold = true },
        -- AvanteReversedTitle = { fg = palette.bright_green, bg = palette.dark0, bold = true },
        -- AvanteSubtitle = { fg = palette.light0, bg = palette.bright_blue, bold = true },
        -- AvanteReversedSubtitle = { fg = palette.bright_blue, bg = palette.dark0, bold = true },
        -- AvanteThirdTitle = { fg = palette.light1, bg = palette.dark1 },
        -- AvanteReversedThirdTitle = { fg = palette.dark1, bg = palette.light1 },
        --
        -- AvanteSuggestion = { link = "Comment" },
        -- AvanteAnnotation = { link = "Comment" },
        -- AvantePopupHint = { link = "NormalFloat" },
        -- AvanteInlineHint = { link = "Keyword" },
        --
        -- AvanteToBeDeleted = { bg = "#cc241d", fg = palette.light1, strikethrough = true }, -- Gruvbox red
        -- AvanteToBeDeletedWOStrikethrough = { bg = palette.dark1, fg = palette.light1 },
        --
        -- AvanteConfirmTitle = { fg = palette.dark0, bg = palette.bright_red, bold = true },
        --
        -- AvanteButtonDefault = { fg = palette.light0, bg = palette.gray },
        -- AvanteButtonDefaultHover = { fg = palette.light0, bg = palette.bright_green, bold = true },
        -- AvanteButtonPrimary = { fg = palette.light0, bg = palette.bright_yellow, bold = true },
        -- AvanteButtonPrimaryHover = { fg = palette.light0, bg = palette.bright_blue, bold = true },
        -- AvanteButtonDanger = { fg = palette.light0, bg = palette.bright_red, bold = true },
        -- AvanteButtonDangerHover = { fg = palette.light0, bg = palette.bright_orange, bold = true },
        --
        -- AvantePromptInput = { link = "NormalFloat" },
        -- AvantePromptInputBorder = { fg = palette.light1, bg = palette.dark0 },

        -- (Optionally add spinner/conflict/other Avante groups here)
      },
      dim_inactive = false,
      transparent_mode = false,
    })

    vim.cmd([[
      set background=dark
      colorscheme gruvbox
      highlight! link StatusLine Normal
      highlight! link StatusLineNC NormalNC
    ]])

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = palette.bright_red, bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = palette.bright_yellow, bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = palette.bright_green, bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = palette.bright_aqua, bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = palette.bright_blue, bg = "", bold = true })
        vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { fg = palette.bright_purple, bg = "", bold = true })

        vim.api.nvim_set_hl(0, "DiffAdd", { fg = "", bg = "" })
        vim.api.nvim_set_hl(0, "DiffChange", { fg = "", bg = "" })
        vim.api.nvim_set_hl(0, "DiffDelete", { fg = "", bg = "" })
      end,
    })
  end,
}
