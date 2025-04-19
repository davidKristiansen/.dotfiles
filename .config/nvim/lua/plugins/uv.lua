-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  'benomahony/uv.nvim',
  cmd = { "UVInit", "UVRunFile", "UVRunSelection", "UVRunFunction" },
  config = function()
    require('uv').setup()
  end,
  init = function()
    local wk = require('which-key')
    wk.add({
      { "<leader>x", group = "uv" },
    })
  end
}
