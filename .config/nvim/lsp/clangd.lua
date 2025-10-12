-- lua/lsp/servers/clangd.lua
-- SPDX-License-Identifier: MIT
return {
  cmd = {
    "clangd",
    "-j=16",
    "--background-index",
    "--background-index-priority=low",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=never",
    "--pch-storage=memory",
    "--pretty",
  },
  init_options = { clangdFileStatus = true },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
  },
}

