-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  'RaafatTurki/hex.nvim',
  opts = {
    -- dump_cmd = 'xxd -g 1 -u -R always',
  },
  keys = {
    { "<leader>hd", ":silent lua require 'hex'.dump()<cr>",   desc = "dump" },
    { "<leader>ha", ":lua require 'hex'.assemble()<cr>",      desc = "assemble" },
    { "<leader>ht", ":silent lua require 'hex'.toggle()<cr>", desc = "toggle" },
  },
  init = function()
    local wk = require('which-key')
    wk.add({
      { "<leader>h", group = "hex" },
    })
  end
}
