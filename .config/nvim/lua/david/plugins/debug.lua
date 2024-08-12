return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-dap.nvim",
    },
    init = function()
      local wk = require('which-key')
      wk.add({
        { "<leader>d",  group = "debug" },
        { "<leader>dl", group = "list" },
      })
    end,
    config = function()
      require('telescope').load_extension('dap')

      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
    keys = {
      { "<leader>db",  function() require("dap").toggle_breakpoint() end, desc = "Toogle breakpoint" },
      { "<leader>dB",  function() require("dap").set_breakpoint() end,    desc = "Set breakpoint" },
      { "<leader>dc",  function() require("dap").continue() end,          desc = "Continue" },
      { "<leader>dC",  function() require("dap").close() end,             desc = "Close" },
      { "<leader>ds",  function() require("dap").step_over() end,         desc = "Step over" },
      { "<leader>di",  function() require("dap").step_into() end,         desc = "Step into" },
      { "<leader>do",  function() require("dap").step_out() end,          desc = "Step out" },
      { "<leader>du",  function() require("dapui").toggle() end,          desc = "Toggle UI" },
      { "<leader>dt",  function() require("dapui").toggle() end,          desc = "Toggle UI" },
      { "<F5>",        function() require("dap").continue() end,          desc = "Continue" },
      { "<F10>",       function() require("dap").step_over() end,         desc = "Step over" },
      { "<F11>",       function() require("dap").step_into() end,         desc = "Step into" },
      { "<F12>",       function() require("dap").step_out() end,          desc = "Step out" },
      { "<leader>dlc", "<cmd>Telescope dap commands<cr>",                 desc = "Commands" },
      { "<leader>dlf", "<cmd>Telescope dap frames<cr>",                   desc = "Frames" },
      { "<leader>dlv", "<cmd>Telescope dap variables<cr>",                desc = "Variables" },
      { "<leader>dlC", "<cmd>Telescope dap configurations<cr>",           desc = "Configurations" },
      { "<leader>dlb", "<cmd>Telescope dap list_breakpoints<cr>",         desc = "Breakpoints" },
    }
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    },
    opts = {},
  },
  {
    'mfussenegger/nvim-dap-python',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    ft = { "python" },
    config = function()
      require("dap-python").setup("python")
    end,
    keys = {
      { "<leader>dn", function() require('dap-python').test_method() end,     desc = "Test mesthod" },
      { "<leader>df", function() require('dap-python').test_class() end,      desc = "Test class" },
      { "<leader>ds", function() require('dap-python').debug_selection() end, desc = "Test selection", mode = { "v" } }
    }
  }
}
