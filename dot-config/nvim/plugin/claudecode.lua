-- SPDX-License-Identifier: MIT
-- claudecode.nvim: Claude Code IDE integration via WebSocket MCP protocol.
-- Keymap-triggered (<leader>a*).

local claude = require('utils.lazy').add({
  src = 'https://github.com/coder/claudecode.nvim',
  config = function()
    require('claudecode').setup({
      git_repo_cwd = true,
      track_selection = true,
      terminal = {
        provider = 'native',
        split_side = 'right',
        split_width_percentage = 0.40,
      },
    })

    -- Bind <leader>as in any neo-tree buffers that were already open at load.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].filetype == 'neo-tree' then
        vim.keymap.set(
          'n',
          '<leader>as',
          '<cmd>ClaudeCodeTreeAdd<cr>',
          { buffer = buf, desc = 'Claude: Add file from tree' }
        )
      end
    end
  end,
  keys = {
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Claude: Toggle' },
    { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Claude: Focus' },
    { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Claude: Resume' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Claude: Add buffer' },
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Claude: Accept diff' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Claude: Deny diff' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Claude: Send selection' },
  },
})

-- Neo-tree: <leader>as adds the file under the cursor to Claude's context.
-- Buffer-local (so it overrides the global visual map per neo-tree buffer) and
-- routed through the shared load guard.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'neo-tree',
  callback = function(ev)
    vim.keymap.set('n', '<leader>as', function()
      claude.load()
      vim.cmd('ClaudeCodeTreeAdd')
    end, { buffer = ev.buf, desc = 'Claude: Add file from tree' })
  end,
})
