-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

local M = {}

function M.setup()
  local enabled_modules = {
    ai = false,
    align = true,
    bufremove = true,
    files = false,
    icons = true,
    pick = false,
    starter = true,
    statusline = true,
    jump = false,
    move = false,
    splitjoin = false,
    surround = true,
    trailspace = false,
    tabline = false,
    git = true,
    diff = false,
  }

  for name, enabled in pairs(enabled_modules) do
    if enabled then
      local has_opts, opts = pcall(require, "plugins.mini.minis." .. name)
      local has_mod, mini_mod = pcall(require, "mini." .. name)

      if has_mod then
        mini_mod.setup(has_opts and opts or {})
      end
    end
  end
end

return M
