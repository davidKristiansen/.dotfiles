return {
  {
    -- dir  = "~/Projects/macpyver.nvim",
    "davidKristiansen/macpyver.nvim",
    cmd  = { "Macpyver" },
    opts = {
      macpyver   = {
        config      = (os.getenv("WORKSPACE") or "/Project") .. "/00.Environment/config/macpyver/macpyver.yaml",
        resources   = (os.getenv("WORKSPACE") or "/Project") .. "/00.Environment/config/macpyver/fpga_resources.yaml",
        output_root = "/tmp/macpyver.out/",
      },
      size       = 90,
      -- auto_close   = true,
      autoscroll = true,
      focus      = false,
      split_dir  = "right",
      keymaps    = { close = "q", ctrlc = "c" },
    },
    keys = {
      { "<leader>mr", "<cmd>Macpyver run<cr>",          desc = "Run test" },
      { "<leader>mc", "<cmd>Macpyver runcase<cr>",      desc = "Run current case" },
      { "<leader>mt", "<cmd>Macpyver runcaseinput<cr>", desc = "Run case from input" },
      { "<leader>mm", "<cmd>Macpyver rerun<cr>",        desc = "Run with args from last run" },
    },
    init = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>m", group = "macpyver" }
      })
    end,
  }
}
