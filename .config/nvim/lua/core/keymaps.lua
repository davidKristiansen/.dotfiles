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
-- Fuzzy / search pickers (mini.pick)

map("n", "<leader>f", ":Pick files<CR>", { desc = "Find files" })
map("n", "<leader>sf", ":Pick files<CR>", { desc = "Search files (alt)" })
map("n", "<leader>sg", ":Pick grep_live<CR>", { desc = "Live grep" })
map("n", "<leader>sb", ":Pick buffers<CR>", { desc = "List buffers" }) -- fixed <bR> typo
map("n", "<leader>sh", ":Pick help<CR>", { desc = "Help tags" })

map("n", "<leader><leader>", function()
  local ok, _ = pcall(function()
    require("mini.pick").builtin.resume()
  end)

  if not ok then
    require("mini.pick").builtin.files()
  end
end, { desc = "Resume search" })


-- LSP convenience (buffer-local ones go in LspAttach)
-- Global formatting (moved from <leader>if)
map("n", "<leader>cf", function() vim.lsp.buf.format() end, { desc = "Format buffer" })

-- Avante Chat
map("n", "<leader>ac", ":AvanteChat<CR>", { desc = "Avante Chat" })

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

map("n", "<leader>gs", ":Git<CR>", { desc = "Fugitive status" })
map("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame (fugitive)" })
map("n", "<leader>gd", ":Gdiffsplit!<CR>", { desc = "Diff (fugitive)" })
map("n", "<leader>gg", ":LazyGit<CR>", { desc = "Lazygit" })

map("n", "<C-Space>", "<cmd>NvimTmuxNavigateNext<CR>", { desc = "Navigate next pane" })


-- Diffview integrations
map("n", "<leader>gD", function()
  vim.cmd("DiffviewOpen")
end, { desc = "Diffview: Open (all diffs)" })

map("n", "<leader>gq", function()
  vim.cmd("DiffviewClose")
end, { desc = "Diffview: Close" })

map("n", "<leader>gh", function()
  -- File history for current file
  vim.cmd("DiffviewFileHistory %")
end, { desc = "Diffview: File history (current file)" })

map("n", "<leader>gH", function()
  -- Repository history (all)
  vim.cmd("DiffviewFileHistory")
end, { desc = "Diffview: Repo history" })

map("n", "<leader>gr", function()
  -- Refresh by closing and reopening (simple approach)
  vim.cmd("DiffviewRefresh")
end, { desc = "Diffview: Refresh" })
