return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      -- enable_diagnostic = true

    },
    keys = {
      { "<leader>fe", "<cmd>Neotree toggle dir=./<cr>", desc = "Explorer" }
    }
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["z"] = { name = "+folds" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>s"] = { name = "+search" },
      }
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
    end
  }
}
