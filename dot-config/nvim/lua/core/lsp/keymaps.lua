-- SPDX-License-Identifier: MIT
-- Single source of truth for all buffer-local LSP keymaps.

local fixall = require("core.lsp.fix_all")

local M = {}

--- Declarative keymap definitions.
--- Each entry: { mode, lhs, rhs, desc }
--- `desc` is auto-prefixed with "LSP: " unless it starts with a category.
---@param bufnr integer
---@return table[]
local function keymaps(bufnr)
    local picker = function(name)
        return function() require("utils.picker")[name]() end
    end

    return {
        -- Navigation
        { "n",          "gd",          picker("lsp_definitions"),      "Go to Definition" },
        { "n",          "grr",         picker("lsp_references"),       "List References" },
        { "n",          "gri",         picker("lsp_implementations"),  "Go to Implementation" },
        { "n",          "grt",         picker("lsp_type_definitions"), "Go to Type Definition" },
        { "n",          "gl",          picker("diagnostics"),          "Line Diagnostics" },
        { "n",          "gD",          vim.lsp.buf.declaration,        "Go to Declaration" },
        { "n",          "gvD",         function() vim.lsp.buf.declaration({ jump_to_location_opts = { command = "vsplit" } }) end,
                                                                       "Go to Declaration (Vertical Split)" },
        { "n",          "grn",         vim.lsp.buf.rename,             "Rename" },

        -- Code actions
        { { "n", "x" }, "gra",         vim.lsp.buf.code_action,                "Code Actions" },
        { { "n", "v" }, "<leader>ca",  vim.lsp.buf.code_action,                "Code Action" },
        { "n",          "<leader>cA",  function() fixall.run(bufnr) end,       "Fix All (source.fixAll)" },

        -- Formatting / toggles
        { "n",          "<leader>cf",  function() vim.lsp.buf.format { async = true } end, "Format Document" },
        { "n",          "<leader>Ta",  function() fixall.toggle_on_save(bufnr) end,        "Toggle: FixAll on save" },

        -- Documentation
        { "n",          "K",           vim.lsp.buf.hover,              "Hover Documentation" },
        { "i",          "<C-k>",       vim.lsp.buf.signature_help,     "Signature Help" },

        -- Diagnostics
        { "n", "[d", function()
            vim.diagnostic.jump({ count = -1 })
            vim.defer_fn(function() vim.diagnostic.open_float(nil, { focus = false }) end, 50)
        end, "Previous Diagnostic" },
        { "n", "]d", function()
            vim.diagnostic.jump({ count = 1 })
            vim.defer_fn(function() vim.diagnostic.open_float(nil, { focus = false }) end, 50)
        end, "Next Diagnostic" },
    }
end

function M.setup(bufnr)
    for _, km in ipairs(keymaps(bufnr)) do
        local mode, lhs, rhs, desc = km[1], km[2], km[3], km[4]
        if desc then desc = "LSP: " .. desc end
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
end

return M
