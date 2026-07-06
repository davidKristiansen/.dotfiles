-- lua/lsp/servers/ty.lua
-- SPDX-License-Identifier: MIT
return {
  -- root_markers = { 'ty.toml', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  settings = {
    ty = {
      diagnosticMode = 'workspace',
      -- configuration = {
      --     environment = {
      --         extra_paths = { "./src" },
      --     },
      -- },
      completions = {
        autoImport = true,
      },
    },
  },
}
