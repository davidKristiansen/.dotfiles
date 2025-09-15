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

  -- Create an autocommand for `MiniFilesBufferCreate` event which calls
  -- |MiniFiles.refresh()| with explicit `content.filter` functions: >lua

  local show_dotfiles = false

  local filter_show = function(fs_entry) return true end

  local filter_hide = function(fs_entry)
    return not vim.startswith(fs_entry.name, '.')
  end

  local toggle_dotfiles = function()
    show_dotfiles = not show_dotfiles
    local new_filter = show_dotfiles and filter_show or filter_hide
    MiniFiles.refresh({ content = { filter = new_filter } })
  end

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
      local buf_id = args.data.buf_id
      -- Tweak left-hand side of mapping to your liking
      vim.keymap.set('n', '.', toggle_dotfiles, { buffer = buf_id })
    end,
  })
end

return M
