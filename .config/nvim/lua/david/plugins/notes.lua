return {
  {
    "nvim-neorg/neorg",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-neorg/neorg-telescope" }
    },
    lazy = true,
    ft = "norg",
    version = "*",
    cmd = { "Neorg" },
    config = {
      load = {
        ["core.defaults"] = {},
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = vim.env.XDG_DATA_HOME .. "/notes"
            },
            index = "index.norg",
            default_workspace = "notes",
          }
        },
        ["core.concealer"] = {
          config = {
            icon_preset = "varied"
          }
        },
        ["core.completion"] = {
          config = {
            engine = "nvim-cmp"
          }
        },
        ["core.journal"] = {
          config = {
            workspace = "notes"
          }
        },
        ["core.esupports.metagen"] = {
          config = {
            author = "David Kristiansen",
            timezone = "implicit-local",
            type = "auto",
            tab = "  "
          }
        },
        ["core.integrations.telescope"] = {}
      }
    },
    init = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>j",  group = "journal" },
        { "<leader>n",  group = "notes" },
        { "<leader>ns", group = "search" }
      })
    end,
    keys = {
      { "<leader>jt",  "<cmd>Neorg journal today<cr>",           desc = "today" },
      { "<leader>jy",  "<cmd>Neorg journal yesterday<cr>",       desc = "yesterday" },
      { "<leader>jm",  "<cmd>Neorg journal tomorrow<cr>",        desc = "tomorrow" },
      { "<leader>ni",  "<cmd>Neorg index<cr>",                   desc = "index" },
      { "<leader>nr",  "<cmd>Neorg return<cr>",                  desc = "return",   ft = "norg" },
      { "<leader>nt",  "<cmd>Neorg toc<cr>",                     desc = "toc",      ft = "norg" },
      { "<leader>nsh", "<Plug>(neorg.telescope.search_heading)", desc = "heading",  ft = "norg" },
    }
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    cmd = { "Obsidian" },
    event = { "BufReadPre " .. vim.env.XDG_DATA_HOME .. "/vault/**/*.md" },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",

      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter"
    },
    opts = {
      -- A list of workspace names, paths, and configuration overrides.
      -- If you use the Obsidian app, the 'path' of a workspace should generally be
      -- your vault root (where the `.obsidian` folder is located).
      -- When obsidian.nvim is loaded by your plugin manager, it will automatically set
      -- the workspace to the first workspace in the list whose `path` is a parent of the
      -- current markdown file being edited.
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
        nvim_cmp = true,
        -- Trigger completion at 2 chars.
        min_chars = 2,
      },
    }
  }
}
