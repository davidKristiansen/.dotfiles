-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, cfg = pcall(require, "nvim-treesitter.configs")
  if not ok then
    vim.notify("nvim-treesitter not available", vim.log.levels.WARN)
    return
  end

  cfg.setup({
    highlight = { enable = true },
    auto_install = true,
    additional_vim_regex_highlighting = false,
  })

  -- Non-blocking first-run parser update (runs once)
  local once = require("utils.once")
  once.run("ts_update", function()
    vim.schedule(function()
      pcall(vim.cmd, "silent! TSUpdate")
    end)
  end)
end

return M

