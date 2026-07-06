-- SPDX-License-Identifier: MIT
-- Global keymaps (non-LSP, non-plugin). Loaded after all plugin/ files via
-- after/plugin/keymaps.lua. Plugin-specific maps live in their plugin/*.lua
-- spec; LSP buffer-local maps in lua/core/lsp/keymaps.lua.
-- Window/pane navigation (<C-h/j/k/l>) lives in plugin/tmux.lua.

local map = vim.keymap.set

-- ---------------------------------------------------------------------
-- Editing
-- ---------------------------------------------------------------------
-- Paste from system clipboard. Uses <leader>P to avoid colliding with the
-- <leader>p* "pi" prefix (a bare <leader>p map would delay every paste by
-- timeoutlen and pollute the which-key pi group).
map({ 'n', 'x' }, '<leader>P', '"+p', { desc = 'Paste from system clipboard' })

-- Move lines / selections
map('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
map('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
map('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { desc = 'Move line down' })
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { desc = 'Move line up' })

-- ---------------------------------------------------------------------
-- Quickfix
-- ---------------------------------------------------------------------
local function toggle_qflist()
  if vim.fn.empty(vim.fn.getqflist()) == 1 then
    vim.notify('Quickfix list is empty', vim.log.levels.INFO)
    return
  end
  if vim.fn.getqflist({ winid = 0 }).winid > 0 then
    vim.cmd('cclose')
  else
    vim.cmd('copen')
  end
end

map('n', '<leader>q', toggle_qflist, { desc = 'Toggle quickfix list' })
map('n', ']q', function()
  if not pcall(vim.cmd, 'cnext') then
    vim.cmd('cfirst')
  end
end, { desc = 'Next quickfix item (wrap)' })
map('n', '[q', function()
  if not pcall(vim.cmd, 'cprev') then
    vim.cmd('clast')
  end
end, { desc = 'Previous quickfix item (wrap)' })

-- ---------------------------------------------------------------------
-- Find (fzf-lua via utils.picker)
-- ---------------------------------------------------------------------
local function pick(fn, opts)
  return function()
    require('utils.picker')[fn](opts)
  end
end

map('n', '<leader>ff', pick('files'), { desc = 'Files' })
map('n', '<leader>fg', pick('live_grep'), { desc = 'Live Grep' })
map('n', '<leader>fb', pick('buffers'), { desc = 'Buffers' })
map('n', '<leader>fh', pick('help_tags'), { desc = 'Help Tags' })
map('n', '<leader>fo', pick('oldfiles'), { desc = 'Old Files' })
map('n', '<leader>fw', pick('grep_cword'), { desc = 'Grep CWORD' })
map('v', '<leader>fw', pick('grep_visual'), { desc = 'Grep selection' })
map('n', '<leader>fj', pick('jumplist'), { desc = 'Jumplist' })
map('n', '<leader>fd', pick('diagnostics'), { desc = 'Diagnostics (buffer)' })
map('n', '<leader>fD', pick('diagnostics', { bufnr = nil }), { desc = 'Diagnostics (workspace)' })
map('n', '<leader>fz', pick('zoxide'), { desc = 'Zoxide' })
map('n', '<leader><leader>', pick('resume'), { desc = 'Resume last picker' })

-- ---------------------------------------------------------------------
-- UI / sessions
-- ---------------------------------------------------------------------
map('n', '<leader>s', pick('sessions'), { desc = 'Sessions' })
map('n', '<leader>h', function()
  local ok, starter = pcall(require, 'mini.starter')
  if ok then
    starter.open()
  end
end, { desc = 'Open start screen' })

-- ---------------------------------------------------------------------
-- Toggles (<leader>T)
-- ---------------------------------------------------------------------
map('n', '<leader>Th', function()
  vim.g.inlay_hints_enabled = not (vim.g.inlay_hints_enabled == true)
  vim.lsp.inlay_hint.enable(vim.g.inlay_hints_enabled)
  vim.notify((vim.g.inlay_hints_enabled and 'Enabled' or 'Disabled') .. ' inlay hints')
end, { desc = 'Toggle Inlay Hints' })

map('n', '<leader>Ti', function()
  vim.lsp.inline_completion.enable(not vim.lsp.inline_completion.is_enabled())
end, { desc = 'Toggle Inline Completion' })

map('n', '<leader>Tf', function()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify((vim.g.format_on_save and 'Enabled' or 'Disabled') .. ' format on save')
end, { desc = 'Toggle Format on Save' })

map('n', '<leader>Tb', function()
  local ok, gitsigns = pcall(require, 'gitsigns')
  if ok then
    gitsigns.toggle_current_line_blame()
  else
    vim.notify('gitsigns not loaded', vim.log.levels.WARN)
  end
end, { desc = 'Toggle Git Blame' })
