-- SPDX-License-Identifier: MIT
-- neo-tree.nvim: file explorer.
-- Loaded on first keymap press (<leader>e).

local loaded = false

local function load_neotree()
  if loaded then return end
  loaded = true

  vim.pack.add({
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/MunifTanjim/nui.nvim' },
    { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim' },

  }, { confirm = false })

  require('neo-tree').setup({
    use_popups_for_input = false,
    enable_git_status    = true,
    filesystem           = { use_libuv_file_watcher = true },
    window               = { mappings = { ['<C-v>'] = 'open_vsplit' } },
  })
end

-- Stub keymap: load neo-tree on first press, then execute the command
vim.keymap.set('n', '<leader>e', function()
  load_neotree()
  vim.cmd('Neotree toggle')
end, { desc = 'Explorer' })
