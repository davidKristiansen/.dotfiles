-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

-- Restore global statusline after leaving dashboard

vim.api.nvim_create_autocmd("User", {
  pattern = "SnacksDashboardClosed",
  callback = function()
    vim.schedule(function()
      vim.opt.laststatus = (vim.env.TMUX and 0 or 3)
    end)
  end,
})

return {
  preset = {
    keys = {
      {
        icon = " ",
        key = "f",
        desc = "Find File",
        action = function()
          require("fzf-lua-enchanted-files").files({ prompt = "Files❯ " })
        end
      },
      { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
      { icon = " ", key = "e", desc = "File Tree", action = function() Snacks.explorer() end },
      { icon = " ", key = "g", desc = "Find Text", action = function() require("fzf-lua").live_grep() end },
      { icon = " ", key = "s", desc = "Sessions", action = function() require("nvim-possession").list() end },
      { icon = " ", key = "N", desc = "Notes", action = "<cmd>ObsidianQuickSwitch<cr>" },
      { icon = " ", key = "G", desc = "Git", action = ":lua Snacks.lazygit()" },
      { icon = " ", key = "r", desc = "Recent Files", action = function() require("fzf-lua").oldfiles() end },
      {
        icon = " ",
        key = "c",
        desc = "Config",
        action = function() require("fzf-lua-enchanted-files").files({ cwd = vim.fn.stdpath('config') }) end
      },
      { icon = " ", key = "S", desc = "Restore Session", section = "session" },
      { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
    },
  },

  sections = {
    { section = "header" },
    -- { pane = 2, section = "terminal", cmd = "onefetch --no-title --no-art", height = 5, padding = 1, },
    { section = "keys",  gap = 1, padding = 1 },
    -- { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    -- { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
    {
      pane = 2,
      icon = " ",
      title = "Git Status",
      section = "terminal",
      enabled = function()
        return Snacks.git.get_root() ~= nil
      end,
      cmd = "onefetch --no-title --no-art || true",
      height = 20,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },
    { section = "startup" },
  },
}
