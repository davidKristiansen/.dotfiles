-- SPDX-License-Identifier: MIT
-- nvim-orgmode: Org-mode for Neovim.
-- Loaded on FileType org OR the agenda/capture keymaps. orgmode installs and
-- manages its own `org` treesitter grammar during setup(), so it stays out of
-- the nvim-treesitter parser list in plugin/02-treesitter.lua.

local org_dir = (os.getenv('XDG_DATA_HOME') or (os.getenv('HOME') .. '/.local/share'))
  .. '/orgfiles'

require('utils.lazy').add({
  src = 'https://github.com/nvim-orgmode/orgmode',
  -- Rendering companions (raw deps: packadd'ed before orgmode loads):
  --   org-bullets  -> icon bullets for headings + checkboxes
  --   org-modern   -> modern floating menus for agenda/capture/export prompts
  deps = {
    'https://github.com/nvim-orgmode/org-bullets.nvim',
    'https://github.com/danilshvalov/org-modern.nvim',
  },
  ft = 'org',
  keys = {
    {
      '<leader>oa',
      function()
        require('orgmode').action('agenda.prompt')
      end,
      desc = 'Org: Agenda',
    },
    {
      '<leader>oc',
      function()
        require('orgmode').action('capture.prompt')
      end,
      desc = 'Org: Capture',
    },
  },
  -- Function form so we can require the (now packadd'ed) org-modern menu module.
  opts = function()
    local Menu = require('org-modern.menu')
    return {
      org_agenda_files = org_dir .. '/**/*',
      org_default_notes_file = org_dir .. '/refile.org',
      -- Match the todo states migrated from the vault todo.md:
      -- [ ]->TODO  [/]->PROGRESS  [>]->WAITING  [x]->DONE
      org_todo_keywords = { 'TODO', 'PROGRESS', 'WAITING', '|', 'DONE' },
      -- Built-in rendering: conceal emphasis markers, collapse leading stars
      -- (org-bullets shows one bullet per heading), prettier fold ellipsis.
      org_hide_emphasis_markers = true,
      org_hide_leading_stars = true,
      org_ellipsis = ' …',
      -- Modern floating menu for agenda/capture/export selection prompts.
      ui = {
        menu = {
          handler = function(data)
            Menu:new({
              window = {
                margin = { 1, 0, 1, 0 },
                padding = { 0, 1, 0, 1 },
                title_pos = 'center',
                border = 'rounded',
                zindex = 1000,
              },
              icons = { separator = '➜' },
            }):open(data)
          end,
        },
      },
    }
  end,
  -- org-bullets has no orgmode hook; start it once orgmode is loaded.
  config = function()
    require('org-bullets').setup()

    -- orgmode installs its buffer-local maps under the <leader>o prefix only in
    -- org buffers; name the second-level groups so which-key stops showing bare
    -- "+N keymaps". Registered buffer-local (these maps don't exist elsewhere).
    -- The lazy loader re-fires FileType after load, so the triggering buffer is
    -- covered too.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'org',
      group = vim.api.nvim_create_augroup('orgmode_which_key', { clear = true }),
      callback = function(ev)
        local ok, wk = pcall(require, 'which-key')
        if not ok then
          return
        end
        wk.add({
          { '<leader>ob', group = 'babel', buffer = ev.buf },
          { '<leader>od', group = 'dates', buffer = ev.buf },
          { '<leader>oi', group = 'insert', buffer = ev.buf },
          { '<leader>ol', group = 'links', buffer = ev.buf },
          { '<leader>on', group = 'note', buffer = ev.buf },
          { '<leader>ox', group = 'clock', buffer = ev.buf },
        })
      end,
    })
  end,
})
