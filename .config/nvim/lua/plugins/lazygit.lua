-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, lazygit = pcall(require, "lazygit")
  if ok then
    lazygit.setup()
  end
end

return M
