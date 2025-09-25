-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "m4xshen/hardtime.nvim",
  cmd = { "Hardtime" },
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    disable_mouse = false,
    disabled_keys = {
      ["<UP>"] = {},
      ["<DOWN>"] = {},
      ["<LEFT>"] = {},
      ["<RIGHT>"] = {},
    }
  },
  keys = {
    { "<leader>He", "<cmd>Hardtime enable<cr>",  desc = "Enable" },
    { "<leader>Hd", "<cmd>Hardtime disable<cr>", desc = "Disable" },
    { "<leader>Ht", "<cmd>Hardtime toggle<cr>",  desc = "Toggle" },
    { "<leader>Hr", "<cmd>Hardtime report<cr>",  desc = "Report" },
  },
  init = function()
    local wk = require('which-key')
    wk.add({
      { "<leader>H", group = "Hardtime" }
    })
  end
}
