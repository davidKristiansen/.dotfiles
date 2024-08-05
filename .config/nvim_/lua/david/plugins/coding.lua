return {
  {
    'echasnovski/mini.align',
    version = '*',
    event = { "BufReadPost", "BufNewFile" },
    config = true
  },

  {
    'echasnovski/mini.comment',
    event = { "BufReadPost", "BufNewFile" },
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
      wk.add({
        { "s",  group = "Surround" },
        { "sa", "<cmd><cr>",       desc = "Add Surrounding" },
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
    init = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>r", group = "Rename" },
      })
    end,
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
  {
    'monaqa/dial.nvim',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group {
        -- default augends used when no group name is specified
        default = {
          augend.hexcolor.new({
            case = "lower"
          }),
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.constant.new {
            elements = { "True", "False" },
            word = false,
            cyclic = true,
          },
          augend.constant.new {
            elements = { "and", "or" },
            word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            cyclic = true, -- "or" is incremented into "and".
          },
          augend.constant.new {
            elements = { "&&", "||" },
            word = false,
            cyclic = true,
          },
          augend.constant.new {
            elements = { "on", "off" },
            word = false,
            cyclic = true,
          },
        },

        -- augends used when group with name `mygroup` is specified
        mygroup = {
          augend.integer.alias.decimal,
          augend.constant.alias.bool,    -- boolean value (true <-> false)
          augend.date.alias["%m/%d/%Y"], -- date (02/19/2022, etc.)
        }
      }
    end,
    keys = {
      {
        '<C-a>',
        mode = { 'n' },
        function()
          require("dial.map").manipulate("increment", "normal")
        end,
        desc = "Increment"
      },
      {
        '<C-x>',
        mode = { 'n' },
        function()
          require("dial.map").manipulate("decrement", "normal")
        end,
        desc = "Decrement"
      },
      {
        'g<C-a>',
        mode = { 'n' },
        function()
          require("dial.map").manipulate("increment", "gnormal")
        end,
        desc = "Increment sequential"
      },
      {
        'g<C-x>',
        mode = { 'n' },
        function()
          require("dial.map").manipulate("decrement", "gnormal")
        end,
        desc = "Decrement sequential"
      },
      {
        '<C-a>',
        mode = { 'v' },
        function()
          require("dial.map").manipulate("increment", "visual")
        end,
        desc = "Increment"
      },
      {
        '<C-x>',
        mode = { 'v' },
        function()
          require("dial.map").manipulate("decrement", "visual")
        end,
        desc = "Decrement"
      },
      {
        'g<C-a>',
        mode = { 'v' },
        function()
          require("dial.map").manipulate("increment", "gvisual")
        end,
        desc = "Increment sequential"
      },
      {
        'g<C-x>',
        mode = { 'v' },
        function()
          require("dial.map").manipulate("decrement", "gvisual")
        end,
        desc = "Decrement sequential"
      },
    }

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
  {
    "theKnightsOfRohan/csvlens.nvim",
    lazy = false,
    dependencies = {
      "akinsho/toggleterm.nvim"
    },
    ft = { "csv" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      direction = "vertical"
    }
  }
}
