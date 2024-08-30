local palette = require('gruvbox').palette
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      { 'echasnovski/mini.icons', version = false },
      "MunifTanjim/nui.nvim",
      {
        's1n7ax/nvim-window-picker',
        opts = {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { 'neo-tree', "neo-tree-popup", "notify", "alpha" },
              -- if the buffer type is one of following, the window will be ignored
              buftype = { 'terminal', "quickfix", "alpha" },
            },
          },
        },
      },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      reveal = true,
      enable_diagnostic = true,
      use_libuv_file_watcher = false,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignore = true,
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
      },
      buffers = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
      },
      default_component_configs = {
        name = {
          -- highlight = { palette.neutral_yellow }
        },
      },
      window = {
        mappings = {
          ["<space>"] = {
            "toggle_node",
            nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
          },
          ["<2-LeftMouse>"] = "open_with_window_picker",
          ["<cr>"] = "open",
          ["<esc>"] = "cancel", -- close preview or floating neo-tree window
          ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
          -- Read `# Preview Mode` for more information
          ["l"] = "focus_preview",
          ["s"] = "open_split",
          ["v"] = "open_vsplit",
          -- ["S"] = "split_with_window_picker",
          -- ["s"] = "vsplit_with_window_picker",
          ["t"] = "open_tabnew",
          -- ["<cr>"] = "open_drop",
          -- ["t"] = "open_tab_drop",
          ["w"] = "open_with_window_picker",
          --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
          ["C"] = "close_node",
          -- ['C'] = 'close_all_subnodes',


          ["z"] = "close_all_nodes",
          --["Z"] = "expand_all_nodes",
          ["a"] = {
            "add",
            -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = "none" -- "none", "relative", "absolute"
            }
          },
          ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
          -- ["c"] = {
          --  "copy",
          --  config = {
          --    show_path = "none" -- "none", "relative", "absolute"
          --  }
          --}
          ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
          ["i"] = "show_file_details",
        }
      }
    },
    keys = {
      { "<leader>fe", "<cmd>Neotree toggle reveal dir=./<cr>", desc = "Explorer" },
      { "\\",         "<cmd>Neotree toggle reveal dir=./<cr>", desc = "Explorer" }
    }
  },
  {
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    keys = {
      { "-", "<CMD>Oil<CR>", mode = "n", desc = "Open parent directory" }
    }
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = {
        spelling = true,
        registers = true,
        marks = true
      },
      defaults = {
        {
          mode = { "n", "v" },
          { "<leader>f", group = "file/find" },
          { "<leader>r", group = "rename" },
          { "<leader>s", group = "search" },
          { "<leader>t", group = "tasks" },
          { "[",         group = "prev" },
          { "]",         group = "next" },
          { "g",         group = "goto" },
          { "z",         group = "folds" },
        } }
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    -- amongst your other plugins
    'akinsho/toggleterm.nvim',
    lazy = false,
    version = "*",
    config = true
  },
}
