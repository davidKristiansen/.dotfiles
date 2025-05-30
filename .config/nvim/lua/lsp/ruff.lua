-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  name = "ruff",
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", ".git", ".venv" },
  init_options = {
    provideFormatter = false,
    settings = {
      args = {}, -- optional extra args
    },
  },
}
