vim.pack.add({
    { src = "https://github.com/3rd/image.nvim" },
    { src = "https://github.com/3rd/diagram.nvim" },
}, { confirm = false })




require("image").setup({
    -- Configuration options go here
    backend = "kitty",
    integrations = {
        markdown = {
            enabled = true,
            clear_in_insert_mode = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown" },
        },
    },

    tmux_show_only_in_active_window = true,
    editor_only_render_when_focused = false,
    window_overlap_clear_enabled = false,
})

require("diagram").setup({
    -- Configuration options go here
    renderer_options = {
        mermaid = {
            background = "#1d2021", -- nil | "transparent" | "white" | "#hex"
            theme = "dark",         -- nil | "default" | "dark" | "forest" | "neutral"
            cli_args = {
                "-p", vim.fn.expand("~/.config/mermaid-puppeteer.json"),
                -- "-c", vim.fn.expand("~/.config/mermaid-config.json"),
            },
        },
    }
})
