-- SPDX-License-Identifier: MIT
-- mini.nvim modules (icons, statusline, starter need early loading).

vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.nvim' },
}, { confirm = false })

local enabled_modules = {
  ai          = false,
  align       = true,
  bufremove   = true,
  files       = false,
  icons       = true,
  pick        = false,
  sessions    = true,
  starter     = true,
  statusline  = true,
  jump        = false,
  move        = false,
  splitjoin   = false,
  surround    = true,
  trailspace  = false,
  tabline     = false,
}

for name, enabled in pairs(enabled_modules) do
  if enabled then
    local has_mod, mini_mod = pcall(require, 'mini.' .. name)
    if has_mod then
      local has_opts, opts = pcall(require, 'plugins.mini.minis.' .. name)
      mini_mod.setup(has_opts and opts or {})
    end
  end
end
