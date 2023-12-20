return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- dependencies = {
    --   "hiphish/nvim-ts-rainbow2"
    -- },
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>",      desc = "Decrement selection", mode = "x" },
    },
    opts = {
      ensure_installed = { "c", "lua", "vim", "python", "jsonc" },
      auto_install = true,
      highlight = {
        enable = true
      },
      -- rainbow = {
      --   enable = true,
      --   -- list of languages you want to disable the plugin for
      --   disable = { 'jsx', 'cpp' },
      --   -- Which query to use for finding delimiters
      --   query = 'rainbow-parens',
      --   -- Highlight the entire buffer all at once
      --   -- strategy = require('ts-rainbow').strategy.global,
      -- }
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end
  }
}
