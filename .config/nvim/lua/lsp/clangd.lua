-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { ".clangd", "compile_commands.json", ".git" },
}

