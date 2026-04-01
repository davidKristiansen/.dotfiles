vim.pack.add({
    { src = "https://github.com/sudo-tee/opencode.nvim" },
}, { confirm = false })

require("opencode").setup({
    preferred_picker = "fzf",
    default_global_keymaps = true,
})
