-- SPDX-License-Identifier: MIT
-- claudecode.nvim: Claude Code IDE integration via WebSocket MCP protocol.
-- Keymap-triggered (<leader>a*).

local claude = require('utils.lazy').add({
  src = 'https://github.com/coder/claudecode.nvim',
  config = function()
    local in_tmux = vim.env.TMUX ~= nil

    -- Custom tmux terminal provider: tracks the pane, saves/restores layout,
    -- and toggles correctly (the built-in 'external' provider can't do this
    -- because `tmux split-window` exits instantly, breaking its job guard).
    local function make_tmux_provider()
      local pane_id = nil
      local outer_layout = nil -- window layout with no Claude pane present
      local inner_layout = nil -- window layout with the Claude pane visible
      local anchor_pane = nil -- pane immediately before Claude in the window's
      -- pane list; used to re-insert Claude at the same list slot on reopen.
      local p = {}

      local function tmux(...)
        return vim.fn.system({ 'tmux', ... }):gsub('%s+$', '')
      end

      -- The pane_id immediately preceding the Claude pane in the window's pane
      -- list. select-layout maps panes to layout cells by list order (not by
      -- id), so re-inserting Claude after the same predecessor keeps that
      -- mapping stable and stops Claude/terminal from swapping cells on toggle.
      local function pane_before_claude()
        local prev = nil
        for line in tmux('list-panes', '-F', '#{pane_id}'):gmatch('[^\n]+') do
          if line == pane_id then
            return prev
          end
          prev = line
        end
        return nil
      end

      -- The Claude pane exists somewhere (visible here or detached/hidden).
      local function pane_alive()
        if not pane_id then
          return false
        end
        vim.fn.system({ 'tmux', 'display-message', '-t', pane_id, '-p', '#{pane_id}' })
        return vim.v.shell_error == 0
      end

      -- The Claude pane is in the current window (i.e. on screen).
      local function pane_visible()
        return pane_alive() and tmux('display-message', '-t', pane_id, '-p', '#{window_id}')
          == tmux('display-message', '-p', '#{window_id}')
      end

      function p.setup(_) end

      function p.is_available()
        return true
      end

      function p.get_active_bufnr()
        return nil -- external pane, no nvim buffer
      end

      function p.open(cmd_string, env_table)
        if pane_visible() then
          tmux('select-pane', '-t', pane_id)
          return
        end
        if pane_alive() then
          -- Hidden in a detached window: pull it back, preserving the running
          -- Claude process (and thus the session).
          outer_layout = tmux('display-message', '-p', '#{window_layout}')
          -- Re-insert after Claude's former neighbour (falling back to the
          -- active pane) so the pane-list order matches inner_layout; without
          -- this, join-pane targets whatever pane is active and select-layout
          -- can map Claude into the wrong cell.
          if anchor_pane then
            tmux('join-pane', '-h', '-s', pane_id, '-t', anchor_pane)
          else
            tmux('join-pane', '-h', '-s', pane_id)
          end
          if inner_layout then
            tmux('select-layout', inner_layout)
          end
          tmux('select-pane', '-t', pane_id)
          return
        end
        outer_layout = tmux('display-message', '-p', '#{window_layout}')
        local args = { 'tmux', 'split-window', '-hf', '-P', '-F', '#{pane_id}' }
        if env_table then
          for k, v in pairs(env_table) do
            table.insert(args, '-e')
            table.insert(args, k .. '=' .. tostring(v))
          end
        end
        table.insert(args, cmd_string)
        pane_id = vim.fn.system(args):gsub('%s+$', '')
      end

      function p.close()
        if pane_visible() then
          -- Detach into a hidden window instead of killing, so the Claude
          -- session survives across toggles.
          inner_layout = tmux('display-message', '-p', '#{window_layout}')
          anchor_pane = pane_before_claude()
          tmux('break-pane', '-d', '-s', pane_id)
          if outer_layout then
            tmux('select-layout', outer_layout)
          end
        end
      end

      function p.simple_toggle(cmd_string, env_table, _)
        if pane_visible() then
          p.close()
        else
          p.open(cmd_string, env_table)
        end
      end

      function p.focus_toggle(cmd_string, env_table, _)
        if not pane_visible() then
          p.open(cmd_string, env_table)
        elseif tmux('display-message', '-p', '#{pane_id}') == pane_id then
          p.close() -- already focused → hide
        else
          tmux('select-pane', '-t', pane_id) -- visible but unfocused → focus
        end
      end

      -- Kill the (possibly detached) Claude pane when nvim exits so it doesn't
      -- linger as an orphaned tmux window.
      vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = function()
          if pane_alive() then
            vim.fn.system({ 'tmux', 'kill-pane', '-t', pane_id })
          end
        end,
      })

      return p
    end

    require('claudecode').setup({
      git_repo_cwd = true,
      track_selection = true,
      terminal = in_tmux and {
        provider = make_tmux_provider(),
      } or {
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
