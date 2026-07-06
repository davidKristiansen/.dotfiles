-- SPDX-License-Identifier: MIT
-- blink.pairs: auto-pairing (loaded on first InsertEnter).

require('utils.lazy').add({
  src = { src = 'https://github.com/saghen/blink.pairs', version = vim.version.range('*') },
  deps = {
    'https://github.com/saghen/blink.download',
  },
  event = 'InsertEnter',
  main = 'blink.pairs',
  opts = {
    highlights = { enabled = true },
  },
})
