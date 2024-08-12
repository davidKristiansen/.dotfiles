return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git"
      }
    },
    main = "ibl",
    opts = {
      indent = {
        char = '▏',
      },
      scope = {
        show_exact_scope = false,
        show_start = false,
        show_end = false
      }
    },
    config = function(_, opts)
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local palette = require('gruvbox').palette
      local hooks = require "ibl.hooks"

      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = palette.neutral_red })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = palette.neutral_yellow })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = palette.neutral_blue })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = palette.neutral_orange })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = palette.neutral_green })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = palette.neutral_purple })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = palette.neutral_aqua })
      end)

      vim.g.rainbow_delimiters = { highlight = highlight }

      require("ibl").setup(vim.tbl_deep_extend("force", { scope = { highlight = highlight } }, opts))
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end
  },
}
