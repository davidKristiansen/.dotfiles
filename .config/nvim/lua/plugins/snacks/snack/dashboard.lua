return {
  enabled = true,
  preset = {
    keys = {
      { icon = " ", key = "f", desc = "Find File", action = function() Snacks.picker.files() end },
      { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
      { icon = " ", key = "e", desc = "File Tree", action = function() Snacks.explorer() end },
      { icon = " ", key = "g", desc = "Find Text", action = function() require("fzf-lua").live_grep() end },
      { icon = " ", key = "s", desc = "Sessions", action = function() require("nvim-possession").list() end },
      { icon = " ", key = "n", desc = "Notes", action = "<cmd>ObsidianQuickSwitch<cr>" },
      { icon = " ", key = "G", desc = "Git", action = ":lua Snacks.lazygit()" },
      { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
      {
        icon = " ",
        key = "c",
        desc = "Config",
        action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})"
      },
      { icon = " ", key = "s", desc = "Restore Session", section = "session" },
      { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
    },
  },
  sections = {
    { section = "header" },
    -- {
    --   pane = 2,
    --   section = "terminal",
    --   cmd = "onefetch --no-title --no-art",
    --   height = 5,
    --   padding = 1,
    -- },
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
      -- cmd = "git status --short --branch --renames",
      cmd = "onefetch --no-title --no-art || true",
      height = 20,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },
    { section = "startup" },
  },
}
