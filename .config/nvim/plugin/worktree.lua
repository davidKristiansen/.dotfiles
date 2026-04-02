-- SPDX-License-Identifier: MIT
-- Git worktree workspace management.

vim.schedule(function()
  local worktree = require('utils.worktree')
  worktree.setup()
end)
