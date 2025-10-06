-- lua/lsp/servers/ruff.lua
-- SPDX-License-Identifier: MIT
return {
  init_options = {
    settings = {
      args = {}, -- e.g. { "--line-length", "100" }
    },
  },
}
