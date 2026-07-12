-- lsp/lua_ls.lua
-- SPDX-License-Identifier: MIT
return {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      hint = { enable = true },
      -- stylua (.stylua.toml, 2-space) owns Lua formatting; EmmyLuaCodeStyle
      -- defaults to 4-space and would re-indent every saved hunk.
      format = { enable = false },
    },
  },
}
