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
    version = "v2.20.8",
    event = { "BufReadPre", "BufNewFile" },
    opts = {}
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
