-- SPDX-License-Identifier: MIT
-- opencode.nvim: AI agent integration.

vim.schedule(function()
  vim.pack.add({
    { src = 'https://github.com/sudo-tee/opencode.nvim' },
  }, { confirm = false })

  require('opencode').setup({
    preferred_picker        = 'fzf',
    default_global_keymaps  = true,
  })
end)
