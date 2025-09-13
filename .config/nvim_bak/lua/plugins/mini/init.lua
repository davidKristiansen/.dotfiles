-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "echasnovski/mini.nvim",
  lazy = false,
  priority = 999,
  version = false,
  config = function()
    local enabled_modules = {
      ai = true,
      align = true,
      bufremove = true,
      jump = true,
      move = true,
      splitjoin = true,
      surround = true,
      trailspace = false,
      tabline = false,
    }

    for name, enabled in pairs(enabled_modules) do
      if enabled then
        local has_opts, opts = pcall(require, "plugins.mini.mini." .. name)
        local has_mod, mini_mod = pcall(require, "mini." .. name)

        if has_mod then
          mini_mod.setup(has_opts and opts or {})
        end
      end
    end
  end,
}
