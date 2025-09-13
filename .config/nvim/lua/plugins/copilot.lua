-- lua/plugins/copilot.lua
-- SPDX-License-Identifier: MIT

local opts = {
  suggestion = { enabled = false }, -- blink will surface completions
  panel      = { enabled = false },
  -- optional: filetype gates
  filetypes  = {
    markdown = true,
    help     = true,
    ["*"]    = true,
  },
}

local M = {}

function M.setup()
  local ok, copilot = pcall(require, "copilot")
  if not ok then return end

  copilot.setup(opts)
end

return M
