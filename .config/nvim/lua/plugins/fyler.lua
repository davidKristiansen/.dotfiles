-- SPDX-License-Identifier: MIT
local M = {}

local opts = {
  -- Changes explorer closing behaviour when a file get selected
  close_on_select = false,
  -- Changes explorer behaviour to auto confirm simple edits
  confirm_simple = true,
  -- Changes explorer behaviour to hijack NETRW
  default_explorer = true,
  -- Changes git statuses visibility
  git_status = {
    enabled = true,
    symbols = {
      Untracked = "●",
      Added = "✚",
      Modified = "●",
      Deleted = "✖",
      Renamed = "➜",
      Copied = "C",
      Conflict = "‼",
      Ignored = "○",
    },
  },
  hooks = {
    on_delete = nil,   -- function(path) end
    on_rename = nil,   -- function(src_path, dst_path) end
    on_highlight = nil -- function(hl_groups, palette) end
  },
  -- Custom icons for various directory states
  icon = {
    directory_collapsed = nil,
    directory_empty = nil,
    directory_expanded = nil,
  },
  -- Changes icon provider
  icon_provider = "mini_icons",
  -- Changes Indentation marker properties
  indentscope = {
    enabled = true,
    group = "FylerIndentMarker",
    marker = "│",
  },
  -- Changes mappings for associated view
  mappings = {
    ["q"] = "CloseView",
    ["<CR>"] = "Select",
    ["<C-t>"] = "SelectTab",
    ["<C-v>"] = "SelectVSplit", -- vertical split (common convention)
    ["<C-s>"] = "SelectSplit",  -- horizontal split (ensure <C-s> is passed through by disabling flow control)
    ["^"] = "GotoParent",
    ["="] = "GotoCwd",
    ["."] = "GotoNode",
    ["#"] = "CollapseAll",
    ["<BS>"] = "CollapseNode",
  },
  -- Auto current buffer tracking
  track_current_buffer = true,
  win = {
    -- Changes buffer options
    kind_presets = {

      split_left_most = {
        width = "42abs",
      },
    },
  },
}

function M.setup()
  local ok, fyler = pcall(require, "fyler")
  if ok then
    fyler.setup(opts)
    -- Always enforce fixed 42-column width for all Fyler windows (robust augroup)
    local group = vim.api.nvim_create_augroup("FylerWidth", { clear = true })
    local function set_fyler_width()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "fyler" then
          -- pcall to avoid errors if window becomes invalid during resize events
          pcall(vim.api.nvim_win_set_width, win, 42)
        end
      end
    end
    -- When the fyler buffer is first created
    vim.api.nvim_create_autocmd({ "FileType" }, {
      group = group,
      pattern = "fyler",
      callback = set_fyler_width,
    })
    -- Enforce on common layout-changing events
    vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "VimResized", "TabEnter" }, {
      group = group,
      callback = set_fyler_width,
    })

    -- Auto-quit Neovim if Fyler is the only remaining window
    vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
      group = group,
      callback = function()
        local wins = vim.api.nvim_list_wins()
        if #wins == 1 then
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == "fyler" then
            -- Schedule to avoid interfering with current autocmd stack
            vim.schedule(function()
              pcall(vim.cmd, "quit")
            end)
          end
        end
      end,
    })
  end
end

local map = vim.keymap.set
map('n', '<leader>e', function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "fyler" then
      return vim.api.nvim_win_close(win, false)
    end
  end
  require('fyler').open({ kind = "split_left_most" })
  -- vim.cmd.Fyler kind="float"
end, { desc = 'Explorer' })

return M
