-- lua/lsp/servers/ruff.lua
-- SPDX-License-Identifier: MIT

return {
  settings = {
    configurationPreference = "filesystemFirst",
    lineLength = 88,
    fixAll = true,
    organizeImports = true,
    showSyntaxErrors = true,
    codeAction = {
      disableRuleComment = {
        enable = true
      },
      fixViolation = {
        enable = false
      }
    },
    lint = {
      enable = true,
      preview = true
    }
  }
}
