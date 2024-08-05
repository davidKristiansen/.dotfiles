local Util = require("david.util")

return {

  {
    'nvim-telescope/telescope.nvim',
    version = false,
    lazy = false,
    event = { "VeryLazy" },
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
          require("telescope").load_extension("ui-select")
        end
      },
      "folke/trouble.nvim",
    },
    cmd = "Telescope",
    opts = {
      pickers = {
        find_files = {
          follow = true
        }
      },
      extensions = {
        smart_open = {
          match_algorithm = "fzf",
          show_scores = true,
        },
        ["ui-select"] = {
          require("telescope.themes").get_dropdown {
            -- even more opts
          }
        },
      }
    },
    keys = {
      { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
      { "<leader>/", Util.telescope("live_grep"),                        desc = "Grep (root dir)" },
      { "<leader>:", "<cmd>Telescope command_history<cr>",               desc = "Command History" },
      {
        "<leader><space>",
        "<cmd>Telescope smart_open<cr>",
        desc =
        "Smart Open"
      },
      -- find
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                         desc = "Buffers" },
      {
        "<leader>ff",
        Util.telescope("files"),
        desc =
        "Find Files (root dir)"
      },
      { "<leader>fF", Util.telescope("files", { cwd = false }),             desc = "Find Files (cwd)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                        desc = "Recent" },
      { "<leader>fR", Util.telescope("oldfiles", { cwd = vim.loop.cwd() }), desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>",                     desc = "commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>",                      desc = "status" },
      { "<leader>gB", "<cmd>Telescope git_branches<CR>",                    desc = "status" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>",                       desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>",                    desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>",       desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>",                 desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>",                        desc = "Commands" },
      {
        "<leader>sd",
        "<cmd>Telescope diagnostics bufnr=0<cr>",
        desc =
        "Document diagnostics"
      },
      {
        "<leader>sD",
        "<cmd>Telescope diagnostics<cr>",
        desc =
        "Workspace diagnostics"
      },
      { "<leader>sg", Util.telescope("live_grep"),                  desc = "Grep (root dir)" },
      { "<leader>sG", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>",               desc = "Help Pages" },
      {
        "<leader>sH",
        "<cmd>Telescope highlights<cr>",
        desc =
        "Search Highlight Groups"
      },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>",                                      desc = "Key Maps" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>",                                    desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>",                                        desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>",                                  desc = "Options" },
      { "<leader>sr", "<cmd>Telescope lsp_references<cr>",                               desc = "References" },
      { "<leader>sR", "<cmd>Telescope resume<cr>",                                       desc = "Resume" },
      { "<leader>sw", Util.telescope("grep_string", { word_match = "-w" }),              desc = "Word (root dir)" },
      { "<leader>sW", Util.telescope("grep_string", { cwd = false, word_match = "-w" }), desc = "Word (cwd)" },
      {
        "<leader>sw",
        Util.telescope("grep_string"),
        mode = "v",
        desc =
        "Selection (root dir)"
      },
      {
        "<leader>sW",
        Util.telescope("grep_string", { cwd = false }),
        mode = "v",
        desc =
        "Selection (cwd)"
      },
      {
        "<leader>uC",
        Util.telescope("colorscheme", { enable_preview = true }),
        desc =
        "Colorscheme with preview"
      },
      {
        "<leader>ss",
        Util.telescope("lsp_document_symbols", {
          symbols = {
            "Class",
            "Function",
            "Method",
            "Constructor",
            "Interface",
            "Module",
            "Struct",
            "Trait",
            "Field",
            "Property",
          },
        }),
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        Util.telescope("lsp_dynamic_workspace_symbols", {
          symbols = {
            "Class",
            "Function",
            "Method",
            "Constructor",
            "Interface",
            "Module",
            "Struct",
            "Trait",
            "Field",
            "Property",
          },
        }),
        desc = "Goto Symbol (Workspace)",
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
    end
  },
  {
    "nvim-telescope/telescope-media-files.nvim",
    opts = {}

  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    config = function(_, opts)
      require('telescope').load_extension('fzf')
    end,
    build =
    'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
  },
  {
    "danielfalk/smart-open.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
    },
    config = function()
      require("telescope").load_extension("smart_open")
    end,
  },
  {
    "EthanJWright/vs-tasks.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      cache_json_conf = true,  -- don't read the json conf every time a task is ran
      cache_strategy = "last", -- can be "most" or "last" (most used / last used)
      config_dir = ".vscode",  -- directory to look for tasks.json and launch.json
      use_harpoon = false,     -- use harpoon to auto cache terminals
      telescope_keys = {       -- change the telescope bindings used to launch tasks
        vertical = '<C-v>',
        split = '<C-p>',
        tab = '<C-t>',
        current = '<CR>',
      },
      autodetect = { -- auto load scripts
        npm = "on"
      },
      terminal = 'toggleterm',
      term_opts = {
        vertical = {
          direction = "vertical",
          size = "80"
        },
        horizontal = {
          direction = "horizontal",
          size = "10"
        },
        current = {
          direction = "float",
        },
        tab = {
          direction = 'tab',
        }
      },
      json_parser = 'vim.fn.json.decode'
    },
    config = function(_, opts)
      require('telescope').load_extension('vstask')
      require("vstask").setup(opts)
    end,
    keys = {
      {
        "<leader>to",
        function()
          require("telescope").extensions.vstask.tasks()
        end,
        desc = "open task list in telescope"
      },
      {
        "<leader>ti",
        function()
          require("telescope").extensions.vstask.inputs()
        end,
        desc = "open the input list, set new input"
      },
      {
        "<leader>th",
        function()
          require("telescope").extensions.vstask.history()
        end,
        desc = "search history of tasks"
      },
      {
        "<leader>tc",
        function()
          require("telescope").extensions.vstask.close()
        end,
        desc = "close the task runner (if toggleterm)"
      }
    }
  }


}
