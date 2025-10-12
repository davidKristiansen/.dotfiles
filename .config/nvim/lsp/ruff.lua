-- lua/lsp/servers/ruff.lua
-- SPDX-License-Identifier: MIT

return {
  settings = {
    args = {},
  },

  -- you already inject this globally; okay to omit here if you prefer
  capabilities = { offsetEncoding = { "utf-16" } },

  single_file_support = true,
}
