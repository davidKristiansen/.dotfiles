-- SPDX-License-Identifier: MIT
-- blink.pairs: auto-pairing (loaded on first InsertEnter).

-- v0.6+ ships the parser as a native library. Prefer the prebuilt binary from
-- the GitHub release (the spec is pinned to a tag, so one exists) and only fall
-- back to cargo, which needs a toolchain new enough for std::hint::cold_path.
local function ensure_library()
  local pairs_ = require('blink.pairs')
  if pairs_.library_available() then return end

  pcall(function()
    pairs_.download():pwait(60000)
  end)
  if pairs_.library_available() then return end

  pcall(function()
    pairs_.build():pwait(60000)
  end)
end

require('utils.lazy').add({
  src = { src = 'https://github.com/saghen/blink.pairs', version = vim.version.range('*') },
  deps = {
    'https://github.com/saghen/blink.lib',
  },
  event = 'InsertEnter',
  on_pack_changed = function(ev)
    if ev.data.spec.name == 'blink.pairs' and ev.data.kind ~= 'delete' then ensure_library() end
  end,
  config = function()
    ensure_library()
    require('blink.pairs').setup({
      highlights = { enabled = true },
    })
  end,
})
