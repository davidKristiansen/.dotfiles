-- SPDX-License-Identifier: MIT

local opts = {
  ui = { border = "rounded" }
}

local M = {}

function M.setup()
  local ok, mason = pcall(require, "mason")
  if ok then
    mason.setup(opts)
  end
end

return M

