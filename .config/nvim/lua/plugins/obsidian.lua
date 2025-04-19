-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  event = { "BufReadPre " .. vim.env.XDG_DATA_HOME .. "/vault/**/*.md" },
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    ui = { enable = false }, -- let render-markdown do it's thing
    picker = {
      name = "fzf-lua",
    },
    workspaces = {
      {
        name = "vault",
        path = vim.env.XDG_DATA_HOME .. "/vault",
        overrides = {
          notes_subdir = "notes",
        },
      },
    },
    daily_notes = {
      folder = "notes/dailies",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      default_tags = { "daily-notes" },
      template = nil,
    },
    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 2,
    },
  },
  keys = {
    { "<leader>fn", "<cmd>ObsidianQuickSwitch<cr>", desc = "Notes" },
  },
}
