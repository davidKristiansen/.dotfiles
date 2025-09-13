return {
  'nvim-flutter/flutter-tools.nvim',
  ft = { "dart" },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim', -- optional for vim.ui.select
  },
  config = true,
  opts = {
    ui = {
      border = "rounded",            -- better than "none"
      notification_style = "plugin", -- "plugin" or "native"
    },
    decorations = {
      statusline = {
        app_version = true,
        device = true,
      }
    },
    -- widget_guides = {
    --   enabled = true, -- highlight nested widgets (very useful for Flutter!)
    -- },
    closing_tags = {
      highlight = "Comment", -- highlight closing tags as comments
      prefix = "// ",        -- e.g. // Stack
      enabled = true
    },
    dev_log = {
      enabled = true,
      open_cmd = "vsplit", -- or "tabedit" "split" or "vsplit"
    },
    debugger = {           -- Experimental, but nice!
      enabled = false,
      run_via_dap = false,
      exception_breakpoints = {},
    },
    lsp = {
      color = { -- show errors in colors
        enabled = true,
      },
      settings = {
        showTodos = true,
        completeFunctionCalls = true,
        renameFilesWithClasses = "prompt", -- or "always"/"never"
        enableSnippets = true,
        updateImportsOnRename = true,
      }
    }
  },
  init = function()
    local wk = require('which-key')
    wk.add({
      { "<leader>F", group = "Flutter" },
    })
  end,
  keys = {
    -- Flutter core commands (use <leader>F + ...)
    { "<leader>Fr", ":FlutterReload<CR>",             desc = "Flutter Hot Reload" },
    { "<leader>FR", ":FlutterRestart<CR>",            desc = "Flutter Hot Restart" },
    { "<leader>Fd", ":FlutterDevices<CR>",            desc = "Flutter Pick Device" },
    { "<leader>Fe", ":FlutterEmulators<CR>",          desc = "Flutter Emulators" },
    { "<leader>Fl", ":FlutterLog<CR>",                desc = "Flutter Dev Log" },
    { "<leader>Fq", ":FlutterQuit<CR>",               desc = "Flutter Quit App" },
    { "<leader>Fo", ":FlutterOutlineToggle<CR>",      desc = "Flutter Outline" },
    { "<leader>Fg", ":FlutterWidgetGuidesToggle<CR>", desc = "Flutter Widget Guides" },
    { "<leader>Fp", ":FlutterPubGet<CR>",             desc = "Flutter Pub Get" },
    { "<leader>Fc", ":FlutterCreateProject<CR>",      desc = "Flutter New Project" },
    { "<leader>Fb", ":FlutterBuild<CR>",              desc = "Flutter Build" },
    { "<leader>Fx", ":FlutterClean<CR>",              desc = "Flutter Clean" },
    { "<leader>Ft", ":FlutterTest<CR>",               desc = "Flutter Test" },
    { "<leader>FP", ":FlutterPubUpgrade<CR>",         desc = "Flutter Pub Upgrade" },

    -- (Optional) fzf-lua integration: Search/devices via fzf if you want!
    -- e.g., { "<leader>FF", ":FzfLua files cwd=lib/", desc = "Find Dart files (fzf-lua)" },
    -- (Add more here as needed, if you use fzf-lua/fzf for file/project navigation)
  }

}
