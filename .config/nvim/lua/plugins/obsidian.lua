-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, obsidian = pcall(require, "obsidian")
  -- if ok then
  --   obsidian.setup({
  --     workspaces = {
  --       {
  --         name = "vault",
  --         path = (os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")) .. "/vault",
  --       }
  --     }
  --   })
  -- end
end

return M
