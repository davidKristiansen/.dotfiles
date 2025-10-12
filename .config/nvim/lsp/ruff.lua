-- lua/lsp/servers/ruff.lua
-- SPDX-License-Identifier: MIT

return {
  -- keep config mostly in pyproject; args non-empty to show up in :LspInfo
  settings = {
    args = { },
  },

  -- you already inject this globally; okay to omit here if you prefer
  capabilities = { offsetEncoding = { "utf-16" } },

  single_file_support = true,
}

