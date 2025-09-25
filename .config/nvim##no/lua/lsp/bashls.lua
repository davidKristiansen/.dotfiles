-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  name = "bashls",
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "zsh" },
  root_markers = { ".git" },
  settings = {
    bashIde = {
      shellcheckPath = "shellcheck",
      explainshellEndpoint = "",
      globPattern = "**/*.[sh,zsh]",
      includeAllWorkspaceSymbols = true,
      highlightParsingErrors = true,
      enableSourceErrorDiagnostics = true,
    },
  },
}
