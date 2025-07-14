-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  name = "ty",
  cmd = { "ty", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", ".git", ".venv", "ty.toml" }
}
