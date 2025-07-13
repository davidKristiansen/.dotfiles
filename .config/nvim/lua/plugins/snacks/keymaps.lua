-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

-- lua/plugins/snacks/keymaps.lua

---@type LazyKeys[]
return {
  -- Top Pickers & Explorer
  { "<leader>e",       function() Snacks.explorer() end,                       desc = "File Explorer" },

  -- Git
  { "<leader>gB",      function() Snacks.gitbrowse() end,                      desc = "Git Browse",               mode = { "n", "v" } },
  { "<leader>gg",      function() Snacks.lazygit() end,                        desc = "Lazygit" },

  -- Other Snacks custom actions
  { "<leader>z",       function() Snacks.zen() end,                            desc = "Toggle Zen Mode" },
  { "<leader>Z",       function() Snacks.zen.zoom() end,                       desc = "Toggle Zoom" },
  { "<leader>.",       function() Snacks.scratch() end,                        desc = "Toggle Scratch Buffer" },
  { "<leader>S",       function() Snacks.scratch.select() end,                 desc = "Select Scratch Buffer" },
  { "<leader>bd",      function() Snacks.bufdelete() end,                      desc = "Delete Buffer" },
  { "<leader>cR",      function() Snacks.rename.rename_file() end,             desc = "Rename File" },
  { "<leader>un",      function() Snacks.notifier.hide() end,                  desc = "Dismiss All Notifications" },
  { "<c-/>",           function() Snacks.terminal.toggle() end,                desc = "Toggle Terminal" },
  { "]]",              function() Snacks.words.jump(vim.v.count1) end,         desc = "Next Reference",           mode = { "n", "t" } },
  { "[[",              function() Snacks.words.jump(-vim.v.count1) end,        desc = "Prev Reference",           mode = { "n", "t" } },

  -- News (custom window)
  {
    "<leader>N",
    desc = "Neovim News",
    function()
      Snacks.win({
        file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = "yes",
          statuscolumn = " ",
          conceallevel = 3,
        },
      })
    end,
  },
}

