-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "bullets-vim/bullets.vim",
  init = function()
    vim.cmd([[
        let g:bullets_delete_last_bullet_if_empty = 1
      ]])
  end
}
