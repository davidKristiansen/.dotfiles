-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, align = pcall(require, "mini.align")
  if ok then
    align.setup()
  end
end

return M

