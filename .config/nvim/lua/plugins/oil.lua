-- SPDX-License-Identifier: MIT

local opts = {
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    natural_order = true,
    -- List of patterns/names always hidden in Oil explorer
    is_always_hidden = function(name, bufnr)
      local always_hidden = {"..", ".git", "__pycache__"}
      -- Check for exact matches
      for _, pat in ipairs(always_hidden) do
        if name == pat then return true end
      end
      -- Check for *.egg-info pattern
      if name:find("%.egg%-info$") then return true end
      return false
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

