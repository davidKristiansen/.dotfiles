vim.pack.add({
    { src = "https://github.com/sudo-tee/opencode.nvim" },
}, { confirm = false })

require("opencode").setup({
    preferred_picker = "fzf",
    -- keymap_prefix = "<leader>a",
    default_global_keymaps = true,

    -- keymap = {
    --
    --     editor = {
    --         ["<leader>ag"] = { "toggle" },
    --         ["<leader>ai"] = { "open_input" },
    --         ["<leader>aI"] = { "open_input_new_session" },
    --         ["<leader>ao"] = { "open_output" },
    --         ["<leader>at"] = { "toggle_focus" },
    --         ["<leader>aT"] = { "timeline" },
    --         ["<leader>aq"] = { "close" },
    --         ["<leader>as"] = { "select_session" },
    --         ["<leader>aR"] = { "rename_session" },
    --         ["<leader>ap"] = { "configure_provider" },
    --         ["<leader>aV"] = { "configure_variant" },
    --         ["<leader>ay"] = { "add_visual_selection", mode = { "v" } },
    --         ["<leader>aY"] = { "add_visual_selection_inline", mode = { "v" } },
    --         ["<leader>az"] = { "toggle_zoom" },
    --         ["<leader>av"] = { "paste_image" },
    --         ["<leader>ad"] = { "diff_open" },
    --         ["<leader>a]"] = { "diff_next" },
    --         ["<leader>a["] = { "diff_prev" },
    --         ["<leader>ac"] = { "diff_close" },
    --         ["<leader>ara"] = { "diff_revert_all_last_prompt" },
    --         ["<leader>art"] = { "diff_revert_this_last_prompt" },
    --         ["<leader>arA"] = { "diff_revert_all" },
    --         ["<leader>arT"] = { "diff_revert_this" },
    --         ["<leader>arr"] = { "diff_restore_snapshot_file" },
    --         ["<leader>arR"] = { "diff_restore_snapshot_all" },
    --         ["<leader>ax"] = { "swap_position" },
    --         ["<leader>att"] = { "toggle_tool_output" },
    --         ["<leader>atr"] = { "toggle_reasoning_output" },
    --         ["<leader>a/"] = { "quick_chat", mode = { "n", "x" } },
    --         ["<c-.>"] = { "toggle_focus", mode = { "n", "x", "i", "t" } },
    --     },
    -- },
})
