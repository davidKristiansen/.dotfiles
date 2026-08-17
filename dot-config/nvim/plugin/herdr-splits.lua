-- SPDX-License-Identifier: MIT
-- herdr integration: seamless <C-h/j/k/l> navigation and <M-h/j/k/l> resizing
-- across Neovim splits and herdr panes -- the herdr analogue of the
-- nvim-tmux-navigation setup in plugin/tmux.lua.
--
-- Only loads inside a herdr pane, and tmux.lua bails out when HERDR_ENV is set,
-- so exactly one of the two ever owns <C-h/j/k/l>. They are treated as mutually
-- exclusive: herdr is not run nested inside tmux.
--
-- This is only half of the integration. The herdr side is a separate install
-- that owns the same chords and forwards them here when the focused pane runs
-- Neovim:
--
--   herdr plugin install lmilojevicc/herdr-splits.nvim
--
-- and its binds live in ~/.config/herdr/config.toml as type = "plugin_action".

require('utils.lazy').add({
  src = 'https://github.com/lmilojevicc/herdr-splits.nvim',

  cond = function()
    return vim.env.HERDR_ENV == '1'
  end,

  -- "Later" tier (upstream suggests VeryLazy). Deliberately not the `keys`
  -- tier: setup() is what writes the generated herdr-splits.conf that the
  -- herdr-side scripts read, so it must not wait for a first keypress.
  opts = {
    -- Managed keys -- setup() writes these into the generated conf
    -- (`herdr plugin config-dir herdr-splits`) so the herdr-side scripts agree
    -- with the mappings below and with the plugin_action binds in config.toml.
    -- Declarations only; the real Neovim mappings are set in `config`.
    -- Everything else keeps upstream defaults (at_edge/nav_at_edge = 'wrap',
    -- unzoom_on_nav = true).
    nav_keys = { left = '<C-h>', down = '<C-j>', up = '<C-k>', right = '<C-l>' },
    resize_keys = { left = '<M-h>', down = '<M-j>', up = '<M-k>', right = '<M-l>' },
  },

  config = function()
    local hs = require('herdr-splits')
    local map = vim.keymap.set

    map('n', '<C-h>', function()
      hs.move_cursor_left()
    end, { desc = 'Navigate left split/pane' })
    map('n', '<C-j>', function()
      hs.move_cursor_down()
    end, { desc = 'Navigate down split/pane' })
    map('n', '<C-k>', function()
      hs.move_cursor_up()
    end, { desc = 'Navigate up split/pane' })
    map('n', '<C-l>', function()
      hs.move_cursor_right()
    end, { desc = 'Navigate right split/pane' })

    map('n', '<M-h>', function()
      hs.resize_left()
    end, { desc = 'Resize split/pane left' })
    map('n', '<M-j>', function()
      hs.resize_down()
    end, { desc = 'Resize split/pane down' })
    map('n', '<M-k>', function()
      hs.resize_up()
    end, { desc = 'Resize split/pane up' })
    map('n', '<M-l>', function()
      hs.resize_right()
    end, { desc = 'Resize split/pane right' })
  end,
})
