return {
  {
    "ellisonleao/gruvbox.nvim",
    version = false,
    lazy = false,
    priority = 1000,
    config = function()
      local palette = require("gruvbox").palette
      require("gruvbox").setup({
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
        inverse = true,    -- invert background for search, diffs, statuslines and errors
        contrast = "hard", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {
          SignColumn = { bg = "none" },
          WinBar = { bg = "none" },
          WinBarNC = { bg = "none" },
          TabLineFill = { bg = "none" },
          TabLine = { bg = "none" },
          TabLineSel = { bg = "none" },
          StatusLine = { bg = "none" },
          StatusLineNC = { bg = "none" },
          CursorLine = { bg = "none" },
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
    end,
  },
  {
    "folke/todo-comments.nvim",
    event        = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts         = {},
    keys         = {
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "TODO's" }
    }
  },
  -- {
  --   "rebelot/kanagawa.nvim",
  --   version = false,
  --   lazy = false,
  --   priority = 1000,
  --   init = function()
  --     vim.api.nvim_create_autocmd("ColorScheme", {
  --       pattern = "kanagawa",
  --       callback = function()
  --         if vim.o.background == "light" then
  --           vim.fn.system("kitty +kitten themes Kanagawa_light")
  --         elseif vim.o.background == "dark" then
  --           vim.fn.system("kitty +kitten themes Kanagawa_dragon")
  --         else
  --           vim.fn.system("kitty +kitten themes Kanagawa")
  --         end
  --       end,
  --     })
  --   end,
  --   config = function()
  --     -- Default options:
  --     require('kanagawa').setup({
  --       compile = false,  -- enable compiling the colorscheme
  --       undercurl = true, -- enable undercurls
  --       commentStyle = { italic = true },
  --       functionStyle = {},
  --       keywordStyle = { italic = true },
  --       statementStyle = { bold = true },
  --       typeStyle = {},
  --       transparent = false,   -- do not set background color
  --       dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
  --       terminalColors = true, -- define vim.g.terminal_color_{0,17}
  --       colors = {             -- add/modify theme and palette colors
  --         palette = {},
  --         theme = {
  --           wave = {},
  --           lotus = {},
  --           dragon = {},
  --           all = {
  --
  --             ui = {
  --               bg_gutter = "none"
  --             }
  --           }
  --         },
  --       },
  --       overrides = function(colors) -- add/modify highlights
  --         local theme = colors.theme
  --         return {
  --           NormalFloat = { bg = "none" },
  --           FloatBorder = { bg = "none" },
  --           FloatTitle = { bg = "none" },
  --
  --           -- Save an hlgroup with dark background and dimmed foreground
  --           -- so that you can use it where your still want darker windows.
  --           -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
  --           NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
  --
  --           -- Popular plugins that open floats will link to NormalFloat by default;
  --           -- set their background accordingly if you wish to keep them dark and borderless
  --           LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
  --           MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
  --           TelescopeTitle = { fg = theme.ui.special, bold = true },
  --           TelescopePromptNormal = { bg = theme.ui.bg_p1 },
  --           TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
  --           TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
  --           TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
  --           TelescopePreviewNormal = { bg = theme.ui.bg_dim },
  --           TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
  --           Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },  -- add `blend = vim.o.pumblend` to enable transparency
  --           PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
  --           PmenuSbar = { bg = theme.ui.bg_m1 },
  --           PmenuThumb = { bg = theme.ui.bg_p2 },
  --
  --         }
  --       end,
  --
  --       theme = "dragon",
  --
  --       background = {     -- map the value of 'background' option to a theme
  --         dark = "dragon", -- try "dragon" !
  --         light = "lotus"
  --       },
  --     })
  --
  --     -- setup must be called before loading
  --     vim.cmd("colorscheme kanagawa")
  --   end,
  -- }
}
