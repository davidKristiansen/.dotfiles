return {
  -- {
  --   "ellisonleao/gruvbox.nvim",
  --   version = false,
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("gruvbox").setup({
  --       undercurl = true,
  --       underline = true,
  --       bold = true,
  --       italic = {
  --         strings = true,
  --         comments = true,
  --         operators = false,
  --         folds = true,
  --       },
  --       strikethrough = true,
  --       invert_selection = false,
  --       invert_signs = false,
  --       invert_tabline = false,
  --       invert_intend_guides = false,
  --       inverse = true, -- invert background for search, diffs, statuslines and errors
  --       contrast = "hard", -- can be "hard", "soft" or empty string
  --       palette_overrides = {},
  --       overrides = {
  --         SignColumn = {bg = "#1d2021"}
  --       },
  --       dim_inactive = false,
  --       transparent_mode = false,
  --     })
  --     vim.cmd([[
  --               set background=dark
  --               colorscheme gruvbox
  --           ]])
  --   end,
  -- },
  {
    "rebelot/kanagawa.nvim",
    version = false,
    lazy = false,
    priority = 1000,
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "kanagawa",
        callback = function()
          if vim.o.background == "light" then
            vim.fn.system("kitty +kitten themes Kanagawa_light")
          elseif vim.o.background == "dark" then
            vim.fn.system("kitty +kitten themes Kanagawa_dragon")
          else
            vim.fn.system("kitty +kitten themes Kanagawa")
          end
        end,
      })
    end,
    config = function()
      -- Default options:
      require('kanagawa').setup({
        compile = false,  -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,   -- do not set background color
        dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        colors = {             -- add/modify theme and palette colors
          palette = {},
          theme = {
            wave = {},
            lotus = {},
            dragon = {},
            all = {

              ui = {
                bg_gutter = "none"
              }

            }
          },
        },
        overrides = function(colors) -- add/modify highlights
          return {}
        end,

        theme = "dragon",

        background = {     -- map the value of 'background' option to a theme
          dark = "dragon", -- try "dragon" !
          light = "lotus"
        },
      })

      -- setup must be called before loading
      vim.cmd("colorscheme kanagawa")
    end,
  }
}
