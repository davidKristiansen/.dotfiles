-- lua/lsp/servers/ty.lua
-- SPDX-License-Identifier: MIT
return {
  settings = {
    ty = {
      diagnosticMode = "workspace",
      experimental = {
        rename = true,
        autoImport = true,
      },
    },
  },
}
