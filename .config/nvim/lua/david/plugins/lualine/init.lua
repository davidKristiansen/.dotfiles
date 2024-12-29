local f = require("david.plugins.lualine.functions")
-- local telescope = require("telescope")

local debug = require("david.debug")


-- local colors = require("kanagawa.colors").setup({ theme = 'dragon' })
return {
  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    event = "VeryLazy",
    -- init = function()
    --   vim.cmd("highlight lualine_c_inactive guibg=NONE")
    --   vim.cmd("highlight lualine_c_normal guibg=NONE")
    -- end,
    dependencies = {
      'kazhala/close-buffers.nvim',
      'nvim-tree/nvim-web-devicons',
      -- 'linrongbin16/lsp-progress.nvim',
      "SmiteshP/nvim-navic",
      -- {
      --   "vimpostor/vim-tpipeline",
      --   config = function()
      --     -- vim.g.tpipeline_refreshcmd = "kitty @ set-tab-title Master test"
      --     -- vim.g.tpipeline_clearstl = 1
      --     -- vim.g.tpipeline_restore = 1
      --     vim.g.tpipeline_autoembed = 1
      --     vim.g.tpipeline_clearstl = 1
      --     -- vim.o.fcs = "stlnc:─,stl:─,vert:│"
      --     -- vim.opt.fillchars:append({ eob = " " })
      --   end
      -- }
    },
    opts = {
      options = {
        theme = require("david.plugins.lualine.theme"),
        -- theme = "gruvbox_dark",
        section_separators = { left = '', right = '' },
        component_separators = { left = '╲', right = '╱ ' },
        globalstatus = true,
         icons_enabled = true,
        ignore_focus = {
          -- "neo-tree",
          "dapui_watches", "dapui_breakpoints",
          "dapui_scopes", "dapui_console",
          "dapui_stacks", "dap-repl"  --dap-repl and not dap_repl -.-
        },
        disabled_filetypes = {
          "neo-tree",
          "alpha",
          -- winbar = {
          -- },
          statusline = {
          "dapui_watches", "dapui_breakpoints",
          "dapui_scopes", "dapui_console",
          "dapui_stacks", "dap-repl"
          },
        },
      },
      extensions = {
        'quickfix',
        'neo-tree',
        'lazy',
        'fugitive',
        'mason',
        'fzf',
        'toggleterm'
      },
      sections = {
        lualine_a = {
          {
            "macro-recording",
            fmt = f.show_macro_recording,
          },
          {
            'mode',
            icons_enabled = true
          },
        },
        lualine_b = {
          {
            'branch',
            on_click = function(num, but, mod)
              -- for x, v in pairs(debug.locals()) do print(x, v) end
              require("fzf-lua").git_branches()
            end
          },
          'diff',
          {
            'diagnostics',
            on_click = function()
              require("fzf-lua").lsp_document_diagnostics()
            end
          }
        },
        lualine_c = {
          {
            'filename', path = 1
          },
        },
        -- lualine_x = {
        --   function()
        --     -- invoke `progress` here.
        --     return require('lsp-progress').progress()
        --   end,
        -- },
        lualine_y = { 'encoding', 'fileformat', 'filetype', 'progress' },
        lualine_z = {
          'location',
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            -- color = { fg = colors.dragonBlack0 },
          }
        }
      },
      winbar = {
        lualine_a = {
          {
            'filename',
            on_click = function(num, but, mod)
              if but == 'm' then
                require("close_buffers").delete({ type = 'this' })
              end
            end
          },
        },
        lualine_c = {
          {
            "navic",
            color_correction = nil,
            navic_opts = nil
          },
        }
      },
      inactive_winbar = {
        lualine_a = {
          {
            'filename',
            on_click = function(num, but, mod)
              if but == 'm' then
                require("close_buffers").delete({ type = 'this' })
              end
            end
          }
        }
      }
    }
  },
  {
    "SmiteshP/nvim-navic",
    opts = {
      lsp = {
        auto_attach = true,
      },
      click = true,
      -- highlight = true,
    }
  },
  {
    'linrongbin16/lsp-progress.nvim',
    config = function()
      require('lsp-progress').setup()
    end
  }
}
