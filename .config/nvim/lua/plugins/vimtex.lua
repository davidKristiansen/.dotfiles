-- SPDX-License-Identifier: MIT

-- VimTeX configuration
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_latexmk = {
  aux_dir = "build",
  out_dir = "build",
  callback = 1,
  continuous = 1,
}
vim.g.vimtex_syntax_enabled = 1
vim.g.vimtex_quickfix_enabled = 1

-- Optional: set up autocommands for tex files if needed
local augroup = vim.api.nvim_create_augroup("VimTeX", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "tex",
  callback = function()
    -- Add any tex-specific settings here
  end,
})

-- Create a .latexmkrc in home or project to handle PDF movement
-- Or use a simpler approach: symlink or configure latexmk to output to root
-- Alternative: use a wrapper script that moves the PDF after compilation
