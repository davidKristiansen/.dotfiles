-- SPDX-License-Identifier: MIT
local neotest = require("neotest")

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*.yml", "*.yaml" },
  callback = function(ev)
    local path = vim.fn.fnamemodify(ev.match, ":p")
    for _, a in pairs(neotest.state.adapters or {}) do
      local ad = a.adapter
      if ad and ad.is_test_file and ad.is_test_file(path) then
        neotest.watch.watch(path)
        neotest.summary.open()
        break
      end
    end
  end,
})
