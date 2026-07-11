-- lsp/rust_analyzer.lua
-- SPDX-License-Identifier: MIT
-- Diagnostics disabled — external tooling owns them.
return {
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false,
      },
    },
  },
}
