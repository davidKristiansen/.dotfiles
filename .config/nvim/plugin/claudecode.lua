-- SPDX-License-Identifier: MIT
-- claudecode.nvim: Claude Code IDE integration via WebSocket MCP protocol.
-- Loaded on first keymap press (<leader>ac or <leader>a* variants).

local loaded = false

local function load()
  if loaded then return end
  loaded = true

  vim.pack.add({
    { src = 'https://github.com/coder/claudecode.nvim' },
  }, { confirm = false })

  local ok, claudecode = pcall(require, 'claudecode')
  if not ok then return end

  claudecode.setup({
    git_repo_cwd = true,
    track_selection = true,
    terminal = {
      provider = 'native',
      split_side = 'right',
      split_width_percentage = 0.40,
    },
  })

  -- Real keymaps (replace stubs)
  vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCode<cr>',           { desc = 'Claude: Toggle' })
  vim.keymap.set('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>',      { desc = 'Claude: Focus' })
  vim.keymap.set('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>',  { desc = 'Claude: Resume' })
  vim.keymap.set('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>',      { desc = 'Claude: Add buffer' })
  vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>',       { desc = 'Claude: Send selection' })
  vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Claude: Accept diff' })
  vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>',   { desc = 'Claude: Deny diff' })

  -- Neo-tree: set keymap for any already-open neo-tree buffers
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == 'neo-tree' then
      vim.keymap.set('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>',
        { buffer = buf, desc = 'Claude: Add file from tree' })
    end
  end
end

-- Stub normal-mode keymaps: load on first press then run the command
local stubs = {
  { '<leader>ac', 'Claude: Toggle',      'ClaudeCode' },
  { '<leader>af', 'Claude: Focus',       'ClaudeCodeFocus' },
  { '<leader>ar', 'Claude: Resume',      'ClaudeCode --resume' },
  { '<leader>ab', 'Claude: Add buffer',  'ClaudeCodeAdd %' },
  { '<leader>aa', 'Claude: Accept diff', 'ClaudeCodeDiffAccept' },
  { '<leader>ad', 'Claude: Deny diff',   'ClaudeCodeDiffDeny' },
}

for _, stub in ipairs(stubs) do
  local lhs, desc, cmd = stub[1], stub[2], stub[3]
  vim.keymap.set('n', lhs, function()
    load()
    vim.cmd(cmd)
  end, { desc = desc })
end

-- Visual stub: send selection
vim.keymap.set('v', '<leader>as', function()
  load()
  local keys = vim.api.nvim_replace_termcodes('<cmd>ClaudeCodeSend<cr>', true, false, true)
  vim.api.nvim_feedkeys(keys, 'm', false)
end, { desc = 'Claude: Send selection' })

-- Neo-tree: add file to Claude context
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'neo-tree',
  callback = function(ev)
    vim.keymap.set('n', '<leader>as', function()
      load()
      vim.cmd('ClaudeCodeTreeAdd')
    end, { buffer = ev.buf, desc = 'Claude: Add file from tree' })
  end,
})
