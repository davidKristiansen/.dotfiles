-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, pick = pcall(require, "mini.pick")
  if ok then
    pick.setup()
  end
end

return M

