return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    cmd = { "ObsidianQuickSwitch" },
    event = { "BufReadPre " .. vim.env.XDG_DATA_HOME .. "/vault/**/*.md" },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",

      -- "hrsh7th/nvim-cmp",
      "ibhagwan/fzf-lua",
      "nvim-treesitter/nvim-treesitter"
    },
    opts = {
      -- A list of workspace names, paths, and configuration overrides.
      -- If you use the Obsidian app, the 'path' of a workspace should generally be
      -- your vault root (where the `.obsidian` folder is located).
      -- When obsidian.nvim is loaded by your plugin manager, it will automatically set
      -- the workspace to the first workspace in the list whose `path` is a parent of the
      -- current markdown file being edited.
      picker = {
        name = "fzf-lua"
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
        -- Optional, if you keep daily notes in a separate directory.
        folder = "notes/dailies",
        -- Optional, if you want to change the date format for the ID of daily notes.
        date_format = "%Y-%m-%d",
        -- Optional, if you want to change the date format of the default alias of daily notes.
        alias_format = "%B %-d, %Y",
        -- Optional, default tags to add to each new daily note created.
        default_tags = { "daily-notes" },
        -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
        template = nil
      },
      -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
      completion = {
        -- Set to false to disable completion.
        nvim_cmp = false,
        -- Trigger completion at 2 chars.
        min_chars = 2,
      },
    },
    keys = {
      { "<leader>fn", "<cmd>ObsidianQuickSwitch<cr>", desc = "Notes" },
    },
  }
}
