local palette = require('gruvbox').palette
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
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
              filetype = { 'neo-tree', "neo-tree-popup", "notify" },
              -- if the buffer type is one of following, the window will be ignored
              buftype = { 'terminal', "quickfix" },
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
          ["<cr>"] = "open_with_window_picker",
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
        ["<leader>t"] = { name = "+tasks" },
        ["<leader>s"] = { name = "+search" },
      }
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
    end
  },
  {
    "luukvbaal/statuscol.nvim",
    branch = "0.10",
    event = { "BufEnter", "WinEnter", "FocusGained" },
    opts = {
      ft_ignore = { "neo-tree" },
      relculright = true,
    }
  },
  {
    -- amongst your other plugins
    'akinsho/toggleterm.nvim',
    lazy = false,
    version = "*",
    config = true
  },
  {
    "lewis6991/satellite.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_only = true,
      excluded_filetypes = { 'neo-tree' },
      width = 1,
      windblend = 70,
      zindex = 100
    }
  }
}
