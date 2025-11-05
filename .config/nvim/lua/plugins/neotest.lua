-- SPDX-License-Identifier: MIT

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },

  { src = "https://github.com/nvim-neotest/neotest" },
  { src = "https://github.com/sluongng/neotest-bazel" },
  { src = "https://github.com/rcasia/neotest-bash" },
  { src = "https://github.com/nvim-neotest/neotest-python" },
  { src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
}, { confirm = false })

require("neotest").setup({
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
