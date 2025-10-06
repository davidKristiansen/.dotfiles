-- lua/lsp/servers/basedpyright.lua
-- SPDX-License-Identifier: MIT
return {
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "basic", -- "basic" or "strict"
        -- Soften noisy stuff if Ruff also reports similar issues:
        diagnosticSeverityOverrides = {
          reportUnusedImport = "none",
          reportUnusedVariable = "none",
        },
      },
    },
  },
}
