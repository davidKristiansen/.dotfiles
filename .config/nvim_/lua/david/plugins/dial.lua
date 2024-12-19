return {
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
}
