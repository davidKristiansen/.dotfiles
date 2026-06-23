-- SPDX-License-Identifier: MIT
-- basedpyright: navigation + refactoring (hover, go-to-def, references, file
-- rename / import updates) only.  Diagnostics fully disabled — ruff + ty own
-- linting and type-checking.
--
-- `analysis.ignore = { "**" }` suppresses ALL diagnostics for every file while
-- leaving language features intact.  This is more robust than per-rule
-- severity overrides, which miss general/lint rules that survive
-- typeCheckingMode = "off" (reportUnusedFunction, reportMissingTypeArgument, …).

return {
  single_file_support = true,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        typeCheckingMode = "off",
        ignore = { "**" },
      },
    },
  },
}
