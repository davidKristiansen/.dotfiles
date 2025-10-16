-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, neotest = pcall(require, "neotest")
  if not ok then return end

  neotest.setup({
    adapters = {
      require("neotest-python")({
        runner = "pytest",
      }),
      require("neotest-bash"),
      require("neotest-bazel"),
    },
    -- Show inline diagnostics
    diagnostic = {
      enabled = true,
    },
    -- Floating window for results
    floating = {
      border = "rounded",
      max_height = 0.6,
      max_width = 0.6,
    },
  })
end

return M
