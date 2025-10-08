-- lua/plugins/which_key.lua
-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, wk = pcall(require, 'which-key')
  if not ok then return end

  -- make the popup actually appear for ], [, g, z, <leader>, etc.
  -- (timeoutlen also matters for how fast the popup shows)
  vim.o.timeout = true
  vim.o.timeoutlen = 300

  wk.setup({
    preset = "helix",
    show_help = false,
    show_keys = false,
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = true },
      presets  = {
        operators = true,
        motions   = true,
        text_objects = true,
        windows   = true,
        nav       = true,   -- includes many [ / ] motions
        z         = true,
        g         = true,
      },
    },
    win = { border = 'rounded', padding = { 1, 2 }, zindex = 1000 },
    layout = { align = 'center' },

    -- 👇 key part: explicit triggers for non-leader prefixes
    triggers = { "auto" },
        -- force popups even if there isn't a user mapping yet (for builtins)
    triggers_nowait = {
      "]", "[", "z", "g",
    },

    -- optional: speed up display independent of timeoutlen (which-key v3+)
    delay = 0,
  })

  -- groups so the header shows something nice
  wk.add({
    { '<leader>a', group = 'ai' },
    { '<leader>c', group = 'code' },
    { '<leader>g', group = 'git'  },
    { '<leader>s', group = 'search' },
    { ']',         group = 'next →' },
    { '[',         group = 'prev ←' },
    { 'g',         group = 'goto'  },
    { 'z',         group = 'folds/scroll' },
  }, { mode = 'n' })

  -- optional: label your bracket motions so the popup is actually informative
  -- (these don't create mappings; they just document them)
  wk.add({
    -- diagnostics
    { ']d', desc = 'Next diagnostic' },
    { '[d', desc = 'Prev diagnostic' },
    -- quickfix/location
    { ']q', desc = 'Next quickfix'   },
    { '[q', desc = 'Prev quickfix'   },
    { ']l', desc = 'Next loclist'    },
    { '[l', desc = 'Prev loclist'    },
    -- folds
    { ']z', desc = 'Next fold'       },
    { '[z', desc = 'Prev fold'       },
    -- gitsigns / diff
    { ']h', desc = 'Next hunk (preview)' },
    { '[h', desc = 'Prev hunk (preview)' },
    { ']c', desc = 'Next change (diff)'   },
    { '[c', desc = 'Prev change (diff)'   },
    -- treesitter textobjects (if you use them)
    { ']]', desc = 'Next function/class'  },
    { '[[', desc = 'Prev function/class'  },
  }, { mode = 'n' })
end

return M

