-- SPDX-License-Identifier: MIT
-- basedpyright: enabled for refactoring (file rename / import updates) only.
-- Diagnostics disabled — ruff + ty handle linting and type-checking.

return {
  single_file_support = true,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        diagnosticSeverityOverrides = {
          reportAny = false,
          reportUnusedImport = false,
          reportMissingTypeStubs = false,
          reportGeneralTypeIssues = false,
          reportPrivateUsage = false,
        },
        useLibraryCodeForTypes = true,
        typeCheckingMode = "off",
      },
    },
  },
}
