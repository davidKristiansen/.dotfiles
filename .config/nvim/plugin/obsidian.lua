-- SPDX-License-Identifier: MIT
-- obsidian.nvim: note-taking integration.
-- Loaded on <leader>n* keymaps OR when opening markdown inside the vault.

local vault_path = (os.getenv('XDG_DATA_HOME') or (os.getenv('HOME') .. '/.local/share')) .. '/vault'

local function realpath(p)
  local ok, r = pcall(vim.loop.fs_realpath, p)
  return (ok and r) or vim.fn.fnamemodify(p, ':p')
end

local vault_roots = { realpath(vim.fn.expand(vault_path)) }

local function is_in_vault(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return false end
  local rp = realpath(name)
  for _, root in ipairs(vault_roots) do
    if rp:sub(1, #root) == root then return true end
  end
  return false
end

require('utils.lazy').add({
  src = 'https://github.com/obsidian-nvim/obsidian.nvim',
  ft = { pattern = 'markdown', cond = function(ev) return is_in_vault(ev.buf) end },
  keys = {
    { '<leader>nn', '<cmd>Obsidian new<cr>',               silent = true, desc = 'Obsidian: New note' },
    { '<leader>no', '<cmd>Obsidian open<cr>',              silent = true, desc = 'Obsidian: Open note/app' },
    { '<leader>ns', '<cmd>Obsidian search<cr>',            silent = true, desc = 'Obsidian: Search' },
    { '<leader>nq', '<cmd>Obsidian quick_switch<cr>',      silent = true, desc = 'Obsidian: Quick switch' },
    { '<leader>nw', '<cmd>Obsidian workspace<cr>',         silent = true, desc = 'Obsidian: Switch workspace' },
    { '<leader>nt', '<cmd>Obsidian today<cr>',             silent = true, desc = 'Obsidian: Today' },
    { '<leader>ny', '<cmd>Obsidian yesterday<cr>',         silent = true, desc = 'Obsidian: Yesterday (workday)' },
    { '<leader>nT', '<cmd>Obsidian tomorrow<cr>',          silent = true, desc = 'Obsidian: Tomorrow (workday)' },
    { '<leader>nd', '<cmd>Obsidian dailies -2 1<cr>',      silent = true, desc = 'Obsidian: Dailies (range)' },
    { '<leader>nM', '<cmd>Obsidian new_from_template<cr>', silent = true, desc = 'Obsidian: New from template' },
    { '<leader>ng', '<cmd>Obsidian tags<cr>',              silent = true, desc = 'Obsidian: Tags' },
  },
  config = function()
    require('obsidian').setup({
      legacy_commands = false,
      workspaces = { { name = 'vault', path = vault_path } },
      -- Disable obsidian.nvim's UI -- render-markdown.nvim handles checkbox rendering
      ui = { enable = false },
    })

    local function bmap(buf, mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, buffer = buf, desc = desc })
    end

    -- Buffer-local keymaps for vault markdown files
    vim.api.nvim_create_autocmd('FileType', {
      pattern  = 'markdown',
      group    = vim.api.nvim_create_augroup('obsidian_note_keymaps', { clear = true }),
      callback = function(ev)
        if not is_in_vault(ev.buf) then return end
        bmap(ev.buf, 'n', '<leader>nb', '<cmd>Obsidian backlinks<cr>',   'Obsidian: Backlinks')
        bmap(ev.buf, 'n', '<leader>nl', '<cmd>Obsidian links<cr>',       'Obsidian: List links in note')
        bmap(ev.buf, 'n', '<leader>nh', '<cmd>Obsidian toc<cr>',         'Obsidian: Table of contents')
        bmap(ev.buf, 'n', '<leader>nr', '<cmd>Obsidian rename<cr>',      'Obsidian: Rename + fix backlinks')
        bmap(ev.buf, 'n', '<leader>nf', '<cmd>Obsidian follow_link<cr>', 'Obsidian: Follow link')
        bmap(ev.buf, 'n', '<leader>nm', '<cmd>Obsidian template<cr>',    'Obsidian: Insert template')
        bmap(ev.buf, 'n', '<leader>np', '<cmd>Obsidian paste_img<cr>',   'Obsidian: Paste image')
        bmap(ev.buf, 'x', '<leader>nL', ':Obsidian link<cr>',            'Obsidian: Link selection -> note')
        bmap(ev.buf, 'x', '<leader>nn', ':Obsidian link_new<cr>',        'Obsidian: New note from selection')
        bmap(ev.buf, 'x', '<leader>ne', ':Obsidian extract_note<cr>',    'Obsidian: Extract selection -> note')

        -- Smart checkbox toggle + auto-move for todo files
        local bufname = vim.api.nvim_buf_get_name(ev.buf)
        if bufname:match('todo%.md$') then
          bmap(ev.buf, 'n', '<leader>nc', function() require('utils.todo').cycle(1) end,  'Todo: Cycle checkbox forward')
          bmap(ev.buf, 'n', '<C-a>',      function() require('utils.todo').cycle(1) end,  'Todo: Cycle checkbox forward')
          bmap(ev.buf, 'n', '<C-x>',      function() require('utils.todo').cycle(-1) end, 'Todo: Cycle checkbox backward')
          bmap(ev.buf, 'n', '<leader>n1', function() require('utils.todo').set('[ ]') end, 'Todo: Set [ ] Inbox')
          bmap(ev.buf, 'n', '<leader>n2', function() require('utils.todo').set('[/]') end, 'Todo: Set [/] In Progress')
          bmap(ev.buf, 'n', '<leader>n3', function() require('utils.todo').set('[>]') end, 'Todo: Set [>] Waiting')
          bmap(ev.buf, 'n', '<leader>n4', function() require('utils.todo').set('[x]') end, 'Todo: Set [x] Done')
        else
          bmap(ev.buf, 'n', '<leader>nc', '<cmd>Obsidian toggle_checkbox<cr>', 'Obsidian: Toggle checkbox')
        end
      end,
    })
  end,
})
