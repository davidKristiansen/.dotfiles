return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    plugins = {
      spelling = true,
      registers = true,
      marks = true
    },
    defaults = {
      ["<leader>b"] = { name = "+buffer" },
      ["<leader>c"] = { name = "+code" },
      ["<leader>f"] = { name = "+file" },
      ["<leader>g"] = { name = "+git" },
      ["<leader>r"] = { name = "+refactor" },
      ["<leader>s"] = { name = "+search" },
      ["<leader>u"] = { name = "+ui" },
      ["["] = { name = "+prev" },
      ["]"] = { name = "+next" },
      ["g"] = { name = "+goto" },
      ["z"] = { name = "+folds" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
