-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

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
  init = function()
    local wk = require('which-key')
    wk.add({
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "file" },
      { "<leader>g", group = "git" },
      { "<leader>r", group = "refactor" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "ui" },
      { "[",         group = "prev" },
      { "]",         group = "next" },
      { "g",         group = "goto" },
      { "z",         group = "folds" },

    })
  end
}
