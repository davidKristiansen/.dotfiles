-- lsp/tinymist.lua
-- SPDX-License-Identifier: MIT
-- Tinymist: Language server for Typst
-- https://github.com/Myriad-Dreamin/tinymist

--- Workaround for Neovim nightly (0.12-dev) crash in client:_register_dynamic.
--- Tinymist dynamically registers methods that Neovim doesn't know about,
--- causing _registration_provider() to return nil and crash at
--- `self.registrations[nil]`. We patch the handler to skip unknown methods.
--- TODO: Remove once https://github.com/neovim/neovim/issues/XXXXX is fixed.
local orig = vim.lsp.handlers["client/registerCapability"]
vim.lsp.handlers["client/registerCapability"] = function(err, result, ctx)
    if result and result.registrations then
        local filtered = {}
        for _, reg in ipairs(result.registrations) do
            local cap = vim.lsp.protocol._request_name_to_server_capability[reg.method]
            if cap then
                table.insert(filtered, reg)
            end
        end
        result.registrations = filtered
    end
    return orig(err, result, ctx)
end

return {
    cmd = { "tinymist" },
    filetypes = { "typst" },
    root_markers = { "typst.toml", ".git" },
    settings = {
        exportPdf = "onSave",
        formatterMode = "typstyle",
        semanticTokens = "disable",
    },
}
