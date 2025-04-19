-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  name = "bashls",
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh" },
  root_markers = { ".git" },
  settings = {
    bashIde = {
      shellcheckPath = "shellcheck",
      explainshellEndpoint = "",
      globPattern = "**/*.sh",
      includeAllWorkspaceSymbols = true,
      highlightParsingErrors = true,
      enableSourceErrorDiagnostics = true,
    },
  },
}
