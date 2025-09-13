-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

-- lua/config/keymaps.lua
local map = vim.keymap.set

-- Yank entire buffer silently to system clipboard
map("n", "<leader>by", function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  vim.fn.setreg("+", table.concat(lines, "\n"))
  vim.notify("Buffer yanked to system clipboard (no prompt)", vim.log.levels.INFO)
end, { desc = "Yank entire buffer silently" })
