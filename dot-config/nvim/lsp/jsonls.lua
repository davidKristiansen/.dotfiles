-- lua/lsp/servers/jsonls.lua
-- SPDX-License-Identifier: MIT
return {
    settings = {
        json = {
            validate = { enable = true },
            -- If you add schemastore.nvim later, wire it here.
            format = {
                keepLines = true,
            }
        },
    },
}
