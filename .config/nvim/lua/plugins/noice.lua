-- SPDX-License-Identifier: MIT
-- lua/plugins/noice.lua
-- Configuration for folke/noice.nvim – replaces UI for messages, cmdline, popupmenu.

vim.pack.add({
    { src = "https://github.com/folke/noice.nvim" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },
}, { confirm = false })

require("noice").setup({
    views = {
        cmdline_popup = {
            backend = "popup",
            relative = "editor",
            position = {
                row = "100%",
                col = 0,
            },
            size = {
                height = "auto",
                width = "100%",
            },
            border = {
                style = "none",
            },
            win_options = {
                winhighlight = {
                    Normal = "NoiceCmdline",
                    IncSearch = "",
                    CurSearch = "",
                    Search = "",
                },
            },
        },
        cmdline_input = {
            view = "cmdline_popup",
            relative = "cursor",
            position = { row = -2, col = 0 },
            size = {
                min_width = 40,
                width = "auto",
                height = "auto",
            },
            border = {
                style = "rounded",
                padding = { 0, 1 },
            },
        },
    },
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
        },
    },
    presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
    },
})
