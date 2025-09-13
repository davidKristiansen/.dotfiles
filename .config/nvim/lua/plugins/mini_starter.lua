-- SPDX-License-Identifier: MIT
-- lua/plugins/mini_starter.lua
-- Configuration for mini.starter (lightweight start screen)

local M = {}

function M.setup()
  local ok, starter = pcall(require, 'mini.starter')
  if not ok then return end

  local logo = {
    '   ╔╗╔╗╔══╗╔══╗╔══╗╔╦╗╔══╗',
    '   ║╚╝║║╔╗║║╔╗║║══╣ ║ ║╔╗║',
    '   ║╔╗║║╠╣║║╠╣║╠══║ ║ ║╠╣║',
    '   ╚╝╚╝╚╝╚╝╚╝╚╝╚══╝ ╩ ╚╝╚╝',
  }

  local items = {
    -- Recent files (5) without current
    starter.sections.recent_files(5, false),
    -- Builtin actions (new file, quit, etc.)
    starter.sections.builtin_actions(),
    -- Custom extras
    { name = 'New file',        action = 'enew',       section = 'Actions' },
    { name = 'Find files',      action = 'Pick files', section = 'Pickers' },
    { name = 'Live grep',       action = 'Pick grep_live', section = 'Pickers' },
    { name = 'Open Oil',        action = 'Oil',        section = 'Files' },
    { name = 'Quit',            action = 'qa',         section = 'Actions' },
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

