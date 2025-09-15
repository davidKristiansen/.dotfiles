-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, files = pcall(require, "mini.files")
  if ok then
    files.setup({
      mappings = {
        close       = 'q',
        go_in       = 'l',
        go_in_plus  = '<CR>',
        go_out      = 'h',
        go_out_plus = 'H',
        mark_goto   = "'",
        mark_set    = 'm',
        reset       = '<BS>',
        reveal_cwd  = '@',
        show_help   = 'g?',
        synchronize = '=',
        trim_left   = '<',
        trim_right  = '>',
      },
      windows = {
        preview = false,
      }
    })
  end
end

return M
