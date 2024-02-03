local dragon_colors = require("kanagawa.colors").setup({ theme = 'dragon' })

return {


  {
    'vimpostor/vim-tpipeline',
    event = "VeryLazy"
  },

  {
    "luukvbaal/statuscol.nvim",
    event = "VeryLazy",
    opts = {}
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = {
        highlight = dragon_colors.dragonBlack3 ,
        -- char = '┊',
      },
      whitespace = {
        highlight = dragon_colors.dragonWhite,
        remove_blankline_trail = false,
    },
    -- scope = { enabled = true, highlight = dragon_colors.dragonRed },
    }
  },

  {
    'RRethy/vim-illuminate',
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      filetypes_denylist = {
        'neo-tree'
      },
      delay = 500
    },
    config = function(_, opts)
      require('illuminate').configure(opts)
    end
  },



  -- {
  --   "xiyaowong/transparent.nvim",
  --   lazy = false,
  --   config = function ()
  --     require("transparent").setup()
  --     -- require('transparent').clear_prefix('lualine')
  --   end
  --
  -- }

}
