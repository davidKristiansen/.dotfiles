-- lua/plugins/which_key.lua
-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, wk = pcall(require, "which-key")
  if not ok then return end

  vim.o.timeout = true
  vim.o.timeoutlen = 400

  wk.setup({
    preset = "helix"
  })

  wk.add({
    { "<leader>a", group = "ai" },
    { "<leader>c", group = "code" },
    { "<leader>g", group = "git" },
    { "<leader>s", group = "search" },
    { "<leader>t", group = "toggles" },
    { "<leader>n", group = "notes" },
    { "]", group = "next →" },
    { "[", group = "prev ←" },
    { "g", group = "goto" },
    { "z", group = "folds/scroll" },
  }, { mode = { "n", "v", "o" } })
  require("which-key").add({
    { "gd", group = "goto" },
  }, { mode = { "n" } })
end

return M
