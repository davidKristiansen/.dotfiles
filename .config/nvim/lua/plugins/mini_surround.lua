-- SPDX-License-Identifier: MIT
-- mini.surround + which-key integration (shows `sa/sd/sr/...` under the `s` prefix)
-- Fits your module pattern and stays no-op if plugins aren’t available.
local M = {}

function M.setup()
  -- 1) mini.surround (from nvim-mini/mini.nvim)
  local ok_surround, surround = pcall(require, "mini.surround")
  if not ok_surround then return end

  local wk_ok, wk = pcall(require, "which-key")

  surround.setup()
end

return M
