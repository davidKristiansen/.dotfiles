return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- "theHamsta/nvim-dap-virtual-text",
      "rcarriga/nvim-dap-ui",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-dap.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      -- "Joakker/lua-json5"
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

      -- table.insert(vim._so_trails, "/?.dylib")
      require('dap.ext.vscode').json_decode = require("david.util").decode_json
      require('dap.ext.vscode').load_launchjs()

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
      dap.listeners.before.disconnect.dapui_config = function()
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
      { "<leader>dr",  function() require("dap").restart() end,           desc = "Restart" },
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
    "jay-babu/mason-nvim-dap.nvim",
    setup = {
      ensure_installed = { "python", "cortex-debug" },
      automatic_installation = true,
      handlers = {}
    }
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    },
    opts = {
      element_mappings = {
        scopes = {
          edit = "e",
          expand = "<CR>",
          repl = "r"
        },
        stacks = {
          open = "o",
          toggle = "t",
        },
        watches = {
          expand = "<CR>",
          remove = "d",
          edit = "e",
          repl = "r"
        },
        breakpoints = {
          open = "o",
          toggle = "t"
        }
      },
      layouts = {
        {
          elements = {
            {
              id = "scopes",
              size = 0.39
            },
            {
              id = "stacks",
              size = 0.39
            },
            {
              id = "breakpoints",
              size = 0.11
            },
            {
              id = "watches",
              size = 0.11
            }
          },
          position = "left",
          size = 40
        },
        {
          elements = {
            {
              id = "repl",
              size = 0.5
            },
            {
              id = "console",
              size = 0.50
            },
          },
          position = "bottom",
          size = 10
        }
      },
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      commented = true,
      enabled = false,
      virt_text_pos = 'inline'
    },
    keys = {
      { "<leader>dv", "<cmd>DapVirtualTextToggle<cr>", "Toogle virtual text" }
    }
  },
  {
    'jedrzejboczar/nvim-dap-cortex-debug',
    dependencies = {
      'mfussenegger/nvim-dap'
    },
    ft = { "c" },
    opts = {},
    -- config = function()
    --
    -- end
  },
  {
    'mfussenegger/nvim-dap-python',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    ft = { "python" },
    config = function()
      require("dap-python").setup("python")
      require('dap.ext.vscode').load_launchjs()
    end,
    keys = {
      { "<leader>dn", function() require('dap-python').test_method() end,     desc = "Test mesthod" },
      { "<leader>df", function() require('dap-python').test_class() end,      desc = "Test class" },
      { "<leader>ds", function() require('dap-python').debug_selection() end, desc = "Test selection", mode = { "v" } }
    }
  },
  -- {
  --   "Joakker/lua-json5",
  --   build = "./install.sh"
  -- }
}
