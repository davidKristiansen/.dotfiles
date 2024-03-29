return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "folke/which-key.nvim",
      "luarocks.nvim"
    },
    opts = true,
    -- ft = "norg",
    -- cmd = "Neorg",
    -- config = function()
    --   require("neorg").setup({
    --     load = {
    --       ["core.defaults"] = {},
    --       ["core.esupports.metagen"] = {
    --         config = {
    --           type = "auto"
    --         }
    --       },
    --       ["core.summary"] = {},
    --       ["core.export"] = {},
    --       ["core.ui.calendar"] = {},
    --       ["core.dirman"] = {
    --         config = {
    --           workspaces = {
    --             work = "~/.notes",
    --           },
    --           index = "index.norg",
    --           default_workspace = "work",
    --           open_last_workspace = true,
    --         },
    --       },
    --       ["core.completion"] = {
    --         config = {
    --           engine = "nvim-cmp",
    --         },
    --       },
    --       ["core.concealer"] = {},
    --     },
    --   })
    -- end,
    init = function()
      local wk = require("which-key")
      wk.register({
        n = {
          name = "notes",
          i = { "<cmd>Neorg index<cr>", "Open index" },
        },
      }, { prefix = "<leader>" })
    end,
  },
  {
    'renerocksai/telekasten.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      "nvim-telescope/telescope-media-files.nvim",
      {
        "renerocksai/calendar-vim"
      }
    },
    cmd = "Telekasten",
    keys = {
      -- {"<leader>z", ":lua require('telekasten').panel()<CR>", desc = "Panel"},

      -- " Function mappings
      { "<leader>zf", ":lua require('telekasten').find_notes()<CR>",                desc = "Find Notes" },
      { "<leader>zd", ":lua require('telekasten').find_daily_notes()<CR>",          desc = "Find Daily Notes" },
      { "<leader>zg", ":lua require('telekasten').search_notes()<CR>",              desc = "Search Notes" },
      { "<leader>zz", ":lua require('telekasten').follow_link()<CR>",               desc = "Follow Link" },
      { "<leader>zT", ":lua require('telekasten').goto_today()<CR>",                desc = "Goto Today" },
      { "<leader>zW", ":lua require('telekasten').goto_thisweek()<CR>",             desc = "Goto This Week" },
      { "<leader>zw", ":lua require('telekasten').find_weekly_notes()<CR>",         desc = "Find Weekly Notes" },
      { "<leader>zn", ":lua require('telekasten').new_note()<CR>",                  desc = "New Notes" },
      { "<leader>zN", ":lua require('telekasten').new_templated_note()<CR>",        desc = "New Templated Note" },
      { "<leader>zy", ":lua require('telekasten').yank_notelink()<CR>",             desc = "Yank Noteline" },
      { "<leader>zc", ":lua require('telekasten').show_calendar()<CR>",             desc = "Show Calendar" },
      { "<leader>zC", ":CalendarT<CR>",                                             desc = "Calendar" },
      { "<leader>zi", ":lua require('telekasten').paste_img_and_link()<CR>",        desc = "Past Image and Link" },
      { "<leader>zt", ":lua require('telekasten').toggle_todo()<CR>",               desc = "Toggle Today" },
      { "<leader>zb", ":lua require('telekasten').show_backlinks()<CR>",            desc = "Show Backlinks" },
      { "<leader>zF", ":lua require('telekasten').find_friends()<CR>",              desc = "Find Friends" },
      { "<leader>zI", ":lua require('telekasten').insert_img_link({ i=true })<CR>", desc = "Insert Image Link" },
      { "<leader>zp", ":lua require('telekasten').preview_img()<CR>",               desc = "Preview Image" },
      { "<leader>zm", ":lua require('telekasten').browse_media()<CR>",              desc = "Browser Media" },
      { "<leader>za", ":lua require('telekasten').show_tags()<CR>",                 desc = "Show Tags" },
      { "<leader>#",  ":lua require('telekasten').show_tags()<CR>",                 desc = "Show Tags" },
      { "<leader>zr", ":lua require('telekasten').rename_note()<CR>",               desc = "Rename Note" },
    },
    opts = {
      home = vim.fn.expand("~/.zettelkasten"),
    },
    init = function()
      local wk = require("which-key")
      wk.register({
        z = {
          name = "+zettelkasten",
        },
      }, { prefix = "<leader>" })
    end,
  },
}
