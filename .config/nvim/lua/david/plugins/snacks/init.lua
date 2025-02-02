vim.api.nvim_set_hl(0, 'SnacksBackdrop', { bg = '#1d2021' })
return {
  {
    "folke/snacks.nvim",
    dependencies = {
      { 'echasnovski/mini.icons', version = false },
      "nvim-tree/nvim-web-devicons"
    },
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      bufdelete = { enabled = true },
      dim = { enabled = true },
      explorer = { enabled = true },
      git = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      lazygit = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      picker = { enabled = true, },
      rename = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = function() require("fzf-lua").files() end },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "e", desc = "File Tree", action = ":lua Snacks.explorer()" },
            { icon = " ", key = "s", desc = "Find Text", action = function() require("fzf-lua").live_grep() end },
            { icon = " ", key = "n", desc = "Notes", action = "<cmd>ObsidianQuickSwitch<cr>" },
            { icon = " ", key = "g", desc = "Git", action = ":lua Snacks.lazygit()" },
            { icon = " ", key = "r", desc = "Recent Files", action = function() require("fzf-lua").oldfiles() end },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = function()
                require("fzf-lua").files { cwd = vim.fn.stdpath('config') }
              end
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
            cmd = "onefetch --no-title --no-art",
            height = 20,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          { section = "startup" },
        },
      },
    },
    keys = {
      { "<leader>e",       function() Snacks.explorer() end,                                       desc = "Explorer" },
      { "<leader>d",       function() Snacks.dashboard() end,                                      desc = "Dashboard" },
      { "<leader>z",       function() Snacks.zen() end,                                            desc = "Toggle Zen Mode" },
      { "<leader>Z",       function() Snacks.zen.zoom() end,                                       desc = "Toggle Zoom" },
      { "<leader>.",       function() Snacks.scratch() end,                                        desc = "Toggle Scratch Buffer" },
      { "<leader>S",       function() Snacks.scratch.select() end,                                 desc = "Select Scratch Buffer" },
      { "<leader>n",       function() Snacks.notifier.show_history() end,                          desc = "Notification History" },
      { "<leader>bd",      function() Snacks.bufdelete() end,                                      desc = "Delete Buffer" },
      { "<leader>cR",      function() Snacks.rename.rename_file() end,                             desc = "Rename File" },
      { "<leader>gB",      function() Snacks.gitbrowse() end,                                      desc = "Git Browse",                  mode = { "n", "v" } },
      { "<leader>gb",      function() Snacks.git.blame_line() end,                                 desc = "Git Blame Line" },
      { "<leader>gf",      function() Snacks.lazygit.log_file() end,                               desc = "Lazygit Current File History" },
      { "<leader>gg",      function() Snacks.lazygit() end,                                        desc = "Lazygit" },
      { "<leader>gl",      function() Snacks.lazygit.log() end,                                    desc = "Lazygit Log (cwd)" },
      { "<leader>un",      function() Snacks.notifier.hide() end,                                  desc = "Dismiss All Notifications" },
      { "<leader>fR",      function() Snacks.rename.rename_file() end,                             desc = "Rename File" },
      { "<c-/>",           function() Snacks.terminal() end,                                       desc = "Toggle Terminal" },
      { "<c-_>",           function() Snacks.terminal() end,                                       desc = "which_key_ignore" },
      { "]]",              function() Snacks.words.jump(vim.v.count1) end,                         desc = "Next Reference",              mode = { "n", "t" } },
      { "[[",              function() Snacks.words.jump(-vim.v.count1) end,                        desc = "Prev Reference",              mode = { "n", "t" } },
      -- { "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
      -- { "<leader>/",       function() Snacks.picker.grep() end,                                    desc = "Grep" },
      -- { "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History" },
      -- { "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart finder" },
      -- -- find
      -- { "<leader>fb",      function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
      -- { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      -- { "<leader>ff",      function() Snacks.picker.files() end,                                   desc = "Find Files" },
      -- { "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
      -- { "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent" },
      -- -- git
      -- { "<leader>gc",      function() Snacks.picker.git_log() end,                                 desc = "Git Log" },
      -- { "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "Git Status" },
      -- -- Grep
      -- { "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
      -- { "<leader>sB",      function() Snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
      -- { "<leader>sg",      function() Snacks.picker.grep() end,                                    desc = "Grep" },
      -- { "<leader>sw",      function() Snacks.picker.grep_word() end,                               desc = "Visual selection or word",    mode = { "n", "x" } },
      -- -- search
      -- { '<leader>s"',      function() Snacks.picker.registers() end,                               desc = "Registers" },
      -- { "<leader>sa",      function() Snacks.picker.autocmds() end,                                desc = "Autocmds" },
      -- { "<leader>sc",      function() Snacks.picker.command_history() end,                         desc = "Command History" },
      -- { "<leader>sC",      function() Snacks.picker.commands() end,                                desc = "Commands" },
      -- { "<leader>sd",      function() Snacks.picker.diagnostics() end,                             desc = "Diagnostics" },
      -- { "<leader>sh",      function() Snacks.picker.help() end,                                    desc = "Help Pages" },
      -- { "<leader>sH",      function() Snacks.picker.highlights() end,                              desc = "Highlights" },
      -- { "<leader>sj",      function() Snacks.picker.jumps() end,                                   desc = "Jumps" },
      -- { "<leader>sk",      function() Snacks.picker.keymaps() end,                                 desc = "Keymaps" },
      -- { "<leader>sl",      function() Snacks.picker.loclist() end,                                 desc = "Location List" },
      -- { "<leader>sM",      function() Snacks.picker.man() end,                                     desc = "Man Pages" },
      -- { "<leader>sm",      function() Snacks.picker.marks() end,                                   desc = "Marks" },
      -- { "<leader>sR",      function() Snacks.picker.resume() end,                                  desc = "Resume" },
      -- { "<leader>sq",      function() Snacks.picker.qflist() end,                                  desc = "Quickfix List" },
      -- { "<leader>uC",      function() Snacks.picker.colorschemes() end,                            desc = "Colorschemes" },
      -- { "<leader>qp",      function() Snacks.picker.projects() end,                                desc = "Projects" },
      -- -- LSP
      -- { "gd",              function() Snacks.picker.lsp_definitions() end,                         desc = "Goto Definition" },
      -- { "gr",              function() Snacks.picker.lsp_references() end,                          nowait = true,                        desc = "References" },
      -- { "gI",              function() Snacks.picker.lsp_implementations() end,                     desc = "Goto Implementation" },
      -- { "gy",              function() Snacks.picker.lsp_type_definitions() end,                    desc = "Goto T[y]pe Definition" },
      -- { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,                             desc = "LSP Symbols" },
    }
  }
}
