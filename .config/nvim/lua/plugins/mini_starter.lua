-- SPDX-License-Identifier: MIT
-- lua/plugins/mini_starter.lua
-- Configuration for mini.starter with rainbow logo fade

local M = {}

function M.setup()
  local ok, starter = pcall(require, 'mini.starter')
  if not ok then return end

  local logo = {
    "      _             _     _ _  __",
    "     | |           (_)   | | |/ /",
    "   __| | __ ___   ___  __| | ' / ",
    "  / _` |/ _` \\ \\ / / |/ _` |  <  ",
    " | (_| | (_| |\\ V /| | (_| | . \\ ",
    "  \\__,_|\\__,_| \\_/ |_|\\__,_|_|\\_\\",
  }

  local items = {
    starter.sections.recent_files(5, false),
    starter.sections.builtin_actions(),
    { name = 'Find files', action = 'Pick files',                    section = 'Pickers' },
    { name = 'Live grep',  action = 'Pick grep_live',                section = 'Pickers' },
    { name = 'Explorer',   action = function() MiniFiles.open() end, section = 'Files' },
  }

  starter.setup({
    evaluate_single = true,
    header = table.concat(logo, '\n'),
    items = items,
    footer = function()
      return ('Loaded %d modules'):format(#vim.tbl_keys(package.loaded))
    end,
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.aligning('center', 'center'),
    },
  })

  ------------------------------------------------------------------------
  -- rainbow fade: red → violet
  ------------------------------------------------------------------------
  local ns = vim.api.nvim_create_namespace('starter_logo_rainbow')

  local rainbow = {
    "#cc241d", -- red
    "#d65d0e", -- orange
    "#d79921", -- yellow
    "#98971a", -- green
    "#689d6a", -- cyan/teal-ish
    "#458588", -- blue
  }
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniStarterOpened',
    callback = function(args)
      local buf = args.buf or vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

      -- Robust: look for trimmed first logo line
      local first_logo_line = logo[1]:gsub("^%s*", ""):gsub("%s*$", "")
      local start_idx
      for i, line in ipairs(lines) do
        if line:gsub("^%s*", ""):gsub("%s*$", "") == first_logo_line then
          start_idx = i - 1
          break
        end
      end
      if not start_idx then return end

      local n_logo_lines = #logo
      for i = 1, n_logo_lines do
        -- map logo line index onto rainbow palette
        local color_idx = math.floor((i - 1) * (#rainbow - 1) / (n_logo_lines - 1)) + 1
        local group = ("StarterRainbowLine%d"):format(i)
        vim.api.nvim_set_hl(0, group, { fg = rainbow[color_idx], default = false })
        vim.api.nvim_buf_add_highlight(buf, ns, group, start_idx + i - 1, 0, -1)
      end
    end,
  })
end

return M
