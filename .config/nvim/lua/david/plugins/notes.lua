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
  -- {
  --   "pysan3/neorg-templates",
  --   dependencies = {
  --     "L3MON4D3/LuaSnip"
  --   },
  --   config = true
  -- }
}
