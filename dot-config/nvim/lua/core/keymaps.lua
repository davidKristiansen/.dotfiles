-- SPDX-License-Identifier: MIT
local map = vim.keymap.set

-- map("n", "<leader>o", ":update<CR>:source<CR>", { desc = "Write buffer and source it" })
-- map("n", "<leader>w", ":write<CR>", { desc = "Write buffer" })
-- map("n", "<leader>q", ":quit<CR>", { desc = "Quit window" })

-- Clipboard
-- map({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
-- map({ "n", "v", "x" }, "<leader>d", '"+d', { desc = "Delete to system clipboard" })
-- Paste from system clipboard. Uses <leader>P to avoid colliding with the
-- <leader>p* "pi" prefix (a bare <leader>p map would delay every paste by
-- timeoutlen and pollute the which-key pi group).
map({ "n", "x" }, "<leader>P", '"+p', { desc = "Paste from system clipboard" })

-- Move lines
local define_move_desc = { down = "Move line down", up = "Move line up" }
map("n", "<A-j>", ":m .+1<CR>==", { desc = define_move_desc.down })
map("n", "<A-k>", ":m .-2<CR>==", { desc = define_move_desc.up })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = define_move_desc.down })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = define_move_desc.up })

-- Tmux navigation
map("n", "<C-h>", "<cmd>NvimTmuxNavigateLeft<CR>", { desc = "Navigate left pane" })
map("n", "<C-j>", "<cmd>NvimTmuxNavigateDown<CR>", { desc = "Navigate down pane" })
map("n", "<C-k>", "<cmd>NvimTmuxNavigateUp<CR>", { desc = "Navigate up pane" })
map("n", "<C-l>", "<cmd>NvimTmuxNavigateRight<CR>", { desc = "Navigate right pane" })
map('n', '<C-\\>', '<cmd>NvimTmuxNavigateLastActive<CR>', { desc = 'Navigate last active pane' })
map("n", "<C-Space>", "<cmd>NvimTmuxNavigateNext<CR>", { desc = "Navigate next pane" })

-- Mini Starter
map("n", "<leader>h", function()
    local ok, starter = pcall(require, 'mini.starter')
    if ok then starter.open() end
end, { desc = "Open start screen" })

-- Quickfix list
local function toggle_qflist()
    if vim.fn.empty(vim.fn.getqflist()) == 1 then
        vim.notify("Quickfix list is empty", vim.log.levels.INFO)
        return
    end
    local qf_winid = vim.fn.getqflist({ winid = 0 }).winid
    if qf_winid > 0 then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end
map("n", "<leader>q", toggle_qflist, { desc = "Toggle quickfix list" })

local function qf_next_wrap()
    local ok, _ = pcall(vim.cmd, "cnext")
    if not ok then
        vim.cmd("cfirst")
    end
end

local function qf_prev_wrap()
    local ok, _ = pcall(vim.cmd, "cprev")
    if not ok then
        vim.cmd("clast")
    end
end

-- Quickfix list navigation
map("n", "[q", qf_prev_wrap, { desc = "Previous quickfix item (wrap)" })
map("n", "]q", qf_next_wrap, { desc = "Next quickfix item (wrap)" })

-- Jumplist
map("n", "<C-o>", "<C-o>", { desc = "Jump backward in jumplist" })
map("n", "<C-i>", "<C-i>", { desc = "Jump forward in jumplist" })

-- Toggles
map("n", "<leader>Th", function()
    if vim.g.inlay_hints_enabled == nil then vim.g.inlay_hints_enabled = true end
    vim.g.inlay_hints_enabled = not vim.g.inlay_hints_enabled
    vim.lsp.inlay_hint.enable(vim.g.inlay_hints_enabled)
    vim.notify(vim.g.inlay_hints_enabled and "Enabled inlay hints" or "Disabled inlay hints")
end, { desc = "Toggle Inlay Hints" })

map("n", "<leader>Ti", function()
    vim.lsp.inline_completion.enable(not vim.lsp.inline_completion.is_enabled())
end, { desc = "Toggle Inline Completion" })

map("n", "<leader>Tf", function()
    vim.g.format_on_save = not vim.g.format_on_save
    vim.notify(vim.g.format_on_save and "Enabled format on save" or "Disabled format on save")
end, { desc = "Toggle Format on Save" })

map("n", "<leader>Tb", function()
    local ok, gitsigns = pcall(require, "gitsigns")
    if ok then
        gitsigns.toggle_current_line_blame()
    else
        vim.notify("gitsigns not loaded", vim.log.levels.WARN)
    end
end, { desc = "Toggle Git Blame" })


-- Find Keymaps (fzf-lua via utils.picker)
vim.keymap.set("n", "<leader>ff", function() require("utils.picker").files() end, { desc = "Files" })
vim.keymap.set("n", "<leader>fg", function() require("utils.picker").live_grep() end, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", function() require("utils.picker").buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", function() require("utils.picker").help_tags() end, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fo", function() require("utils.picker").oldfiles() end, { desc = "Old Files" })
vim.keymap.set("n", "<leader>fw",
    function() require("utils.picker").grep_cword() end,
    { desc = "Grep CWORD" })
vim.keymap.set("v", "<leader>fw", function()
    require("utils.picker").grep_visual()
end, { desc = "Grep selection" })
-- vim.keymap.set("n", "*",
--     function() require("utils.picker").current_buffer_lines({ default_text = vim.fn.expand("<cWORD>") }) end,
--     { desc = "Current buffer fuzzy find CWORD" })
-- vim.keymap.set("n", "/", function() require("utils.picker").current_buffer_lines() end,
--     { desc = "Live Grep (current buffer)" })
vim.keymap.set("n", "<leader><leader>", function() require("utils.picker").resume() end, { desc = "Resume" })
vim.keymap.set("n", "<leader>fj", function() require("utils.picker").jumplist() end, { desc = "Jumplist" })
vim.keymap.set("n", "<leader>fd", function() require("utils.picker").diagnostics() end, { desc = "Diagnostic" })
vim.keymap.set("n", "<leader>fz", function() require("utils.picker").zoxide() end, { desc = "Zoxide" })
vim.keymap.set("n", "<leader>fD", function()
    require("utils.picker").diagnostics({ bufnr = nil })
end, { desc = "Diagnostics (workspace)" })

-- Session picker (mini.sessions)
vim.keymap.set("n", "<leader>s", function() require("utils.picker").sessions() end, { desc = "Sessions" })
