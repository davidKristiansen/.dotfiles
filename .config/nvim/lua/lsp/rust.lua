-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  name = "rust-analyzer",
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
      diagnostics = { enable = true },
      completion = { postfix = { enable = true } },
    },
  },
}
