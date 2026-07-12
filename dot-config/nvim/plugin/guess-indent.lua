-- SPDX-License-Identifier: MIT
-- guess-indent: detect each file's indent style and set shiftwidth/expandtab to match.

require('utils.lazy').add({
  src = 'https://github.com/NMAC427/guess-indent.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {},
})
