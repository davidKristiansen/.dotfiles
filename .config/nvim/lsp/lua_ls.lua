-- lua/lsp/servers/lua_ls.lua
-- SPDX-License-Identifier: MIT
return {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
            telemetry   = { enable = false },
            hint        = { enable = true },
        },
    },
}
