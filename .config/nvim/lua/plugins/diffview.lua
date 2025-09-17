-- lua/plugins/diffview.lua
-- SPDX-License-Identifier: MIT
local M = {}

local opts = {
  enhanced_diff_hl = true,
  view = {
    default = { layout = "diff2_horizontal" }, -- open with HEAD..REMOTE → LEFT=local, RIGHT=remote
    merge_tool = {
      layout = "diff3_horizontal",             -- ours | base | theirs  (L | M | R)
      disable_diagnostics = true,
    },
  },
  keymaps = {
    disable_defaults = true, -- ditch built-ins so our LEFT/RIGHT brain wins
    -- Use the *list* form: { mode, lhs, rhs_fn, { desc = "..." } }
    view = (function()
      local a = require("diffview.actions")
      return {
        { "n", "<leader>cl", a.conflict_choose("ours"),   { desc = "Choose LEFT (local/ours)" } },
        { "n", "<leader>cr", a.conflict_choose("theirs"), { desc = "Choose RIGHT (remote/theirs)" } },
        { "n", "<leader>cm", a.conflict_choose("base"),   { desc = "Choose MIDDLE (base)" } },
        { "n", "<leader>ca", a.conflict_choose("all"),    { desc = "Choose ALL hunks" } },

        { "n", "q",          a.close,                     { desc = "Close Diffview" } },
        { "n", "]h",         a.select_next_entry,         { desc = "Next entry" } },
        { "n", "[h",         a.select_prev_entry,         { desc = "Prev entry" } },
        { "n", "gr",         a.refresh_files,             { desc = "Refresh files" } },
        { "n", "gf",         a.goto_file_edit,            { desc = "Open file in editor" } },
        { "n", "<leader>t",  a.focus_files,               { desc = "Focus files panel" } },
      }
    end)(),
    file_panel = (function()
      local a = require("diffview.actions")
      return {
        { "n", "q",       a.close,         { desc = "Close panel" } },
        { "n", "<tab>",   a.focus_entry,   { desc = "Focus entry" } },
        { "n", "<S-tab>", a.toggle_files,  { desc = "Toggle files panel" } },
        { "n", "gr",      a.refresh_files, { desc = "Refresh files" } },
      }
    end)(),
    file_history_panel = (function()
      local a = require("diffview.actions")
      return {
        { "n", "q",     a.close,            { desc = "Close history panel" } },
        { "n", "<tab>", a.open_in_diffview, { desc = "Open in diffview" } },
        { "n", "gr",    a.refresh_files,    { desc = "Refresh history" } },
      }
    end)(),
  },
}

function M.setup()
  local ok, diff = pcall(require, "diffview")
  if not ok then return end
  diff.setup(opts)

  -- Openers that guarantee LEFT=local, RIGHT=remote (HEAD..REMOTE)
  vim.keymap.set("n", "<leader>du", function()
    vim.cmd("DiffviewOpen HEAD..@{u}")
  end, { silent = true, desc = "Diff: local vs upstream (LEFT=local, RIGHT=remote)" })

  vim.keymap.set("n", "<leader>dm", function()
    vim.cmd("DiffviewOpen HEAD..origin/main")
  end, { silent = true, desc = "Diff: local vs origin/main (LEFT=local, RIGHT=remote)" })

  vim.keymap.set("n", "<leader>df", ":DiffviewFileHistory %<CR>",
    { silent = true, desc = "Diff: file history (current file)" })

  vim.keymap.set("n", "<leader>do", function()
    local sha = vim.fn.expand("<cword>")
    if sha:match("^[0-9a-fA-F]+$") then
      vim.cmd(("DiffviewOpen %s^!"):format(sha))
    else
      vim.notify("No commit hash under cursor", vim.log.levels.WARN)
    end
  end, { silent = true, desc = "Diff: commit under cursor (this commit only)" })
end

return M
