-- lua/plugins/which_key.lua
-- SPDX-License-Identifier: MIT

vim.pack.add({
  { src = "https://github.com/folke/which-key.nvim" },
}, { confirm = false })

vim.o.timeout = true
vim.o.timeoutlen = 400

local wk = require("which-key")

wk.setup({
  preset = "helix"
})

wk.add({
  { "<leader>a", group = "ai" },
  { "<leader>c", group = "code" },
  { "<leader>g", group = "git" },
  { "<leader>s", group = "search" },
  { "<leader>T", group = "toggles" },
  { "<leader>t", group = "tests" },
  { "<leader>n", group = "notes" },
  { "]", group = "next →" },
  { "[", group = "prev ←" },
  { "g", group = "goto" },
  { "z", group = "folds/scroll" },
}, { mode = { "n", "v", "o" } })
require("which-key").add({
  { "gd", group = "goto" },
}, { mode = { "n" } })
