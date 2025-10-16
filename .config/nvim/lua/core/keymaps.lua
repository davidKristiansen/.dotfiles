-- SPDX-License-Identifier: MIT
local map = vim.keymap.set



map("n", "<leader>o", ":update<CR>:source<CR>", { desc = "Write buffer and source it" })
map("n", "<leader>w", ":write<CR>", { desc = "Write buffer" })
map("n", "<leader>q", ":quit<CR>", { desc = "Quit window" })

-- Clipboard helpers (no <CR>, they’re Normal-mode ops)
map({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v", "x" }, "<leader>d", '"+d', { desc = "Delete to system clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })

-- Plugin UX

-- Move lines (Alt-j / Alt-k)
-- Normal mode: move current line
local define_move_desc = { down = "Move line down", up = "Move line up" }
map("n", "<A-j>", ":m .+1<CR>==", { desc = define_move_desc.down })
map("n", "<A-k>", ":m .-2<CR>==", { desc = define_move_desc.up })

-- Visual mode: move selected block and reselect
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Insert mode: move line then return to insert at original column
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = define_move_desc.down })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = define_move_desc.up })

-- Tmux navigation (nvim-tmux-navigation) keymaps
map("n", "<C-h>", "<cmd>NvimTmuxNavigateLeft<CR>", { desc = "Navigate left pane" })
map("n", "<C-j>", "<cmd>NvimTmuxNavigateDown<CR>", { desc = "Navigate down pane" })
map("n", "<C-k>", "<cmd>NvimTmuxNavigateUp<CR>", { desc = "Navigate up pane" })
map("n", "<C-l>", "<cmd>NvimTmuxNavigateRight<CR>", { desc = "Navigate right pane" })
map('n', '<C-\\>', '<cmd>NvimTmuxNavigateLastActive<CR>', { desc = 'Navigate last active pane' })

-- Mini Starter (start screen)
map("n", "<leader>ss", function()
  local ok, starter = pcall(require, 'mini.starter')
  if ok then starter.open() end
end, { desc = "Open start screen" })

map("n", "<C-Space>", "<cmd>NvimTmuxNavigateNext<CR>", { desc = "Navigate next pane" })


map("n", "<leader>th", function ()
  if vim.g.inlay_hints_enabled == nil then
    vim.g.inlay_hints_enabled = true
  end
  vim.g.inlay_hints_enabled = not vim.g.inlay_hints_enabled
  vim.lsp.inlay_hint.enable(vim.g.inlay_hints_enabled)
  if vim.g.inlay_hints_enabled then
    vim.notify("Enabled inlay hints")
  else
    vim.notify("Disabled inlay hints")
  end
end, { desc = "Toggle Inlay Hints" })

map("n", "<leader>ti", function ()
  vim.lsp.inline_completion.enable( not vim.lsp.inline_completion.is_enabled())
end, { desc = "Toggle Inline Completion" })

map("n", "<leader>tf", function ()
  vim.g.format_on_save = not vim.g.format_on_save
  if vim.g.format_on_save then
    vim.notify("Enabled format on save")
  else
    vim.notify("Disabled format on save")
    end
end, { desc = "Toggle Format on Save" })
