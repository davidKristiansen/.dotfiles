return {
  {
    "gennaro-tedesco/nvim-possession",
    lazy = false,
    build = function()
      local sessions_path = vim.fn.stdpath("data") .. "/sessions"
      if vim.fn.isdirectory(sessions_path) == 0 then
        vim.uv.fs_mkdir(sessions_path, 511) -- 0777
      end
    end,
    dependencies = {
      "ibhagwan/fzf-lua",
    },
    opts = {
      autoload = false,
      autosave = true,
      autoswitch = {
        enable = true
      },
      -- save_hook = function()
      --   -- Get visible buffers
      --   local visible_buffers = {}
      --   for _, win in ipairs(vim.api.nvim_list_wins()) do
      --     visible_buffers[vim.api.nvim_win_get_buf(win)] = true
      --   end
      --
      --   local buflist = vim.api.nvim_list_bufs()
      --   for _, bufnr in ipairs(buflist) do
      --     if visible_buffers[bufnr] == nil then   -- Delete buffer if not visible
      --       vim.cmd("bd " .. bufnr)
      --     end
      --   end
      -- end
    },
    keys = {
      { "<leader>sl", function() require("nvim-possession").list() end, desc = "📌list sessions", },
      { "<leader>sn", function() require("nvim-possession").new() end, desc = "📌create new session", },
      { "<leader>su", function() require("nvim-possession").update() end, desc = "📌update current session", },
      { "<leader>sd", function() require("nvim-possession").delete() end, desc = "📌delete selected session" },
    },
  }
}
