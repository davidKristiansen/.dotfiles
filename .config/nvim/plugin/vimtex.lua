-- SPDX-License-Identifier: MIT
-- VimTeX: LaTeX support (loaded on FileType tex).

require('utils.lazy').add({
  src = 'https://github.com/lervag/vimtex',
  ft = 'tex',
  init = function()
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_compiler_latexmk = {
      aux_dir    = 'build',
      out_dir    = 'build',
      callback   = 1,
      continuous = 1,
    }
    vim.g.vimtex_syntax_enabled   = 1
    vim.g.vimtex_quickfix_enabled = 1
  end,
})
