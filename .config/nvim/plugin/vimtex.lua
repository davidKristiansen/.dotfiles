-- SPDX-License-Identifier: MIT
-- VimTeX configuration (loaded on FileType tex).

-- Globals must be set before the plugin loads
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_compiler_latexmk = {
  aux_dir    = 'build',
  out_dir    = 'build',
  callback   = 1,
  continuous = 1,
}
vim.g.vimtex_syntax_enabled   = 1
vim.g.vimtex_quickfix_enabled = 1

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'tex',
  once = true,
  callback = function()
    vim.pack.add({
      { src = 'https://github.com/lervag/vimtex' },
    }, { confirm = false })
  end,
})
