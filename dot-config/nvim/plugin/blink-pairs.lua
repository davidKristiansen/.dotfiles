-- SPDX-License-Identifier: MIT
-- blink.pairs: auto-pairing (loaded on first InsertEnter).

require('utils.lazy').add({
  src = { src = 'https://github.com/saghen/blink.pairs', version = vim.version.range('*') },
  deps = {
    'https://github.com/saghen/blink.download',
  },
  event = 'InsertEnter',
  on_pack_changed = function(ev)
    if ev.data.spec.name == 'blink.pairs' and ev.data.kind ~= 'delete' then
      pcall(function()
        require('blink.pairs').build():pwait()
      end)
    end
  end,
  config = function()
    pcall(function()
      require('blink.pairs').build():pwait()
    end)
    require('blink.pairs').setup({
      highlights = { enabled = true },
    })
  end,
})
