-- SPDX-License-Identifier: MIT
-- mini.nvim modules (icons, statusline, starter need early loading; eager).

require('utils.lazy').add({
  src = 'https://github.com/nvim-mini/mini.nvim',
  lazy = false,
  config = function()
    -- Deterministic setup order; icons must precede statusline (which uses them).
    local modules =
      { 'icons', 'statusline', 'starter', 'sessions', 'align', 'bufremove', 'surround' }

    for _, name in ipairs(modules) do
      local has_mod, mini_mod = pcall(require, 'mini.' .. name)
      if has_mod then
        local has_opts, opts = pcall(require, 'plugins.mini.minis.' .. name)
        mini_mod.setup(has_opts and opts or {})
      end
    end
  end,
})
