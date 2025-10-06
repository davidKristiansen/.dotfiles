-- lua/lsp/servers/clangd.lua
-- SPDX-License-Identifier: MIT
return {
  cmd = { "clangd", "--background-index", "--clang-tidy" },
  init_options = { clangdFileStatus = true },
}
