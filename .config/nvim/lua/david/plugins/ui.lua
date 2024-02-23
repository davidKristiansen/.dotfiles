-- local dragon_colors = require("kanagawa.colors").setup({ theme = 'dragon' })



return {
  {
    "lewis6991/satellite.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_only = true,
      excluded_filetypes = { 'neo-tree', 'alpha' },
      width = 1,
      windblend = 70,
      zindex = 100
    }
  },
  {
    "luukvbaal/statuscol.nvim",
    branch = "0.10",
    event = { "BufEnter", "WinEnter", "FocusGained" },
    opts = {
      ft_ignore = { "neo-tree" },
      relculright = true,
    }
  },
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
        show_start = false
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
  {
    'RRethy/vim-illuminate',
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      filetypes_denylist = {
        'neo-tree',
        'alpha'
      },
      delay = 500
    },
    config = function(_, opts)
      require('illuminate').configure(opts)
    end
  },
  {
    'goolord/alpha-nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    init = function()
      vim.cmd([[
        autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
      ]])
    end,
    config = function()
      local alpha = require("alpha")
      local dashboard = require"alpha.themes.dashboard"

      dashboard.section.buttons.val = {
             dashboard.button( "e", "  New file" , ":ene <BAR> startinsert <CR>"),
             dashboard.button( "q", "󰅚  Quit NVIM" , ":qa<CR>"),
      }
         local handle = io.popen('fortune $HOME/.local/share/fortune/fortunes')
         local fortune = handle:read("*a")
         handle:close()
         dashboard.section.footer.val = fortune

         dashboard.config.opts.noautocmd = true

         vim.cmd[[autocmd User AlphaReady echo 'ready']]

         alpha.setup(dashboard.config)
     end
  }
}
