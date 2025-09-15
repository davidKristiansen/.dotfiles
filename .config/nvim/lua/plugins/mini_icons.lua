-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, icons = pcall(require, "mini.icons")
  if ok then
    icons.setup()
  end
end

return M

