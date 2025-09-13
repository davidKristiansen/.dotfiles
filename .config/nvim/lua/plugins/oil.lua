-- SPDX-License-Identifier: MIT

local opts = {
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    natural_order = true,
    is_always_hidden = function(name, bufnr)
      return vim.startswith(name, ".." or name == ".git")
    end,
  },
  win_options = {
    wrap = true,
  },
}

local M = {}

function M.setup()
  local ok, oil = pcall(require, "oil")
  if ok then
    oil.setup(opts)
  end
end

return M

