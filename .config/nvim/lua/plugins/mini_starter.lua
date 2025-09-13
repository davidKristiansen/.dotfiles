-- SPDX-License-Identifier: MIT
-- lua/plugins/mini_starter.lua
-- Configuration for mini.starter (lightweight start screen)

local M = {}

function M.setup()
  local ok, starter = pcall(require, 'mini.starter')
  if not ok then return end

  local logo = {
    "     _                 _        _   _          _    ",
    "  __| | __ ___   _____| |_ ___ | |_| |__   ___| | __",
    " / _` |/ _` \\ \\ / / _ \\ __/ _ \\| __| '_ \\ / _ \\ |/ /",
    "| (_| | (_| |\\ V /  __/ || (_) | |_| | | |  __/   < ",
    " \\__,_|\\__,_| \\_/ \\___|\\__\\___/ \\__|_| |_|\\___|_|\\_\\",
  }

  local items = {
    -- Recent files (5) without current
    starter.sections.recent_files(5, false),
    -- Builtin actions (new file, quit, etc.)
    starter.sections.builtin_actions(),
    -- Custom extras
    { name = 'Find files',      action = 'Pick files', section = 'Pickers' },
    { name = 'Live grep',       action = 'Pick grep_live', section = 'Pickers' },
    { name = 'Open Oil',        action = 'Oil',        section = 'Files' },
  }

  starter.setup({
    evaluate_single = true, -- If only one item remains after filtering, execute it immediately
    header = table.concat(logo, '\n'),
    items = items,
    footer = function()
      local stats = ('Loaded %d modules'):format(#vim.tbl_keys(package.loaded))
      return stats
    end,
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.aligning('center', 'center'),
    },
  })
end

return M

