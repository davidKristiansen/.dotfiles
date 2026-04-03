-- SPDX-License-Identifier: MIT
-- blink.pairs: auto-pairing (loaded on first InsertEnter).

vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  callback = function()
    vim.pack.add({
      { src = 'https://github.com/saghen/blink.pairs', version = vim.version.range('*') },
      { src = 'https://github.com/saghen/blink.download' },
    }, { confirm = false })

    require('blink.pairs').setup({
      highlights = { enabled = true },
    })
  end,
})
