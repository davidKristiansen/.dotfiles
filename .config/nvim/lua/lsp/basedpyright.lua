-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  name = "basedpyright",
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".venv", ".git" },
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
  end,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "basic", -- can also be "strict"
      },
    },
  },
}
