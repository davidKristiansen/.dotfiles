return {
  {
    'echasnovski/mini.comment',
    event = "VeryLazy",
    version = false,
    config = true
  },

  {
    'echasnovski/mini.pairs',
    event = { "InsertEnter" },
    version = false,
    config = true
  },

  {
    'echasnovski/mini.surround',
    dependencies = {
      "folke/which-key.nvim"
    },
    init = function()
      local wk = require("which-key")
      wk.register({
        s = {
          name = "Surround",
          a = { "<cmd><cr>", "Add Surrounding" }
        }
      })
    end,
    keys = {

    },
    version = false,
    opts = {}
  },
  {
    "smjonas/inc-rename.nvim",
    opts = {},
    keys = {
      { "<leader>rn", "<leader>rn", ":IncRename ", desc = "Rename" },
      {
        "<leader>rN",
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        desc = "Rename (copy word)",
        expr = true
      }
    },
  },

  --   {
  --   "echasnovski/mini.surround",
  --   keys = function(_, keys)
  --     -- Populate the keys based on the user's options
  --     local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
  --     local opts = require("lazy.core.plugin").values(plugin, "opts", false)
  --     local mappings = {
  --       { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
  --       { opts.mappings.delete, desc = "Delete surrounding" },
  --       { opts.mappings.find, desc = "Find right surrounding" },
  --       { opts.mappings.find_left, desc = "Find left surrounding" },
  --       { opts.mappings.highlight, desc = "Highlight surrounding" },
  --       { opts.mappings.replace, desc = "Replace surrounding" },
  --       { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
  --     }
  --     mappings = vim.tbl_filter(function(m)
  --       return m[1] and #m[1] > 0
  --     end, mappings)
  --     return vim.list_extend(mappings, keys)
  --   end,
  --   opts = {
  --     mappings = {
  --       add = "gza", -- Add surrounding in Normal and Visual modes
  --       delete = "gzd", -- Delete surrounding
  --       find = "gzf", -- Find surrounding (to the right)
  --       find_left = "gzF", -- Find surrounding (to the left)
  --       highlight = "gzh", -- Highlight surrounding
  --       replace = "gzr", -- Replace surrounding
  --       update_n_lines = "gzn", -- Update `n_lines`
  --     },
  --   },
  -- }
}
