return {
  {
    dir  = "~/Projects/macpyver.nvim",
    cmd  = { "MacpyverRun", "MacpyverCase" },
    ft   = { "yaml" },
    opts = {
      config_path    = os.getenv("WORKSPACE") .. "/00.Environment/config/macpyver/macpyver.yaml",
      resources_path = os.getenv("WORKSPACE") .. "/00.Environment/config/macpyver/fpga_resources.yaml",
      output_root    = "/tmp/macpyver.out/",
      min_width      = 90,
      min_wheight    = 30,
      auto_close     = true,
      autoscroll     = true,
      focus_on_run   = false,
      split_type     = "vertical"
    },
    keys = {
      { "<leader>mr", "<cmd>MacpyverRun<cr>",  desc = "Macpyver Run" },
      { "<leader>mc", "<cmd>MacpyverCase<cr>", desc = "Macpyver run current case" },
    },
    init = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>m", group = "macpyver" }
      })
    end,
  }
}
