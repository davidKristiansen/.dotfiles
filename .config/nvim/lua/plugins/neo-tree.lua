-- SPDX-License-Identifier: MIT

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },

  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
  { src = "https://github.com/s1n7ax/nvim-window-picker",  version = vim.version.range('3') },
  { src = "https://github.com/3rd/image.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
}, { confirm = false })


require("neo-tree").setup({
  window = {
    mappings = {
      ["<C-v>"] = "open_vsplit", }
  }
})

local map = vim.keymap.set
map('n', '<leader>e', "<cmd>Neotree toggle<CR>", { desc = 'Explorer' })
