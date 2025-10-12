-- SPDX-License-Identifier: MIT
local util = require("lspconfig.util")

return {
  single_file_support = true,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "basic",
        diagnosticSeverityOverrides = {
          reportUnusedImport = "none",
          reportUnusedVariable = "none",
          reportUnusedFunction = "none",
          reportUnusedClass = "none",
        },
      },
    },
  },
}

