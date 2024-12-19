return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = {
        spelling = true,
        registers = true,
        marks = true
      },
      defaults = {
        {
          mode = { "n", "v" },
          { "<leader>f", group = "file/find" },
          { "<leader>r", group = "rename" },
          { "<leader>s", group = "search" },
          { "<leader>t", group = "tasks" },
          { "[",         group = "prev" },
          { "]",         group = "next" },
          { "g",         group = "goto" },
          { "z",         group = "folds" },
        } }
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
  },
  {
    -- amongst your other plugins
    'akinsho/toggleterm.nvim',
    lazy = false,
    version = "*",
    config = true
  },
}
