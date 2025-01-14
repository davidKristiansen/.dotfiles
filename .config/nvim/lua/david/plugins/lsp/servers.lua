local M = {}

M.opts = {
  lua_ls = {
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
        return
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME
            -- Depending on the usage, you might want to add additional paths here.
            -- "${3rd}/luv/library"
            -- "${3rd}/busted/library",
          }
          -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
          -- library = vim.api.nvim_get_runtime_file("", true)
        }
      })
    end,
    settings = {
      Lua = {}
    }
  },
  bashls = {

  },
  basedpyright = {
    settings = {
      basedpyright = {
        disableOrganizeImports = true,
        -- disableTaggedHints = true,
        analysis = {
          autoImportCompletions = false,
          ignore = { '*' },
          typeCheckingMode = "off",
          diagnosticMode = "openFilesOnly",
          -- autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        }
      },
    },
  },
  ruff = {},
  -- pyright = {
  --   python = {
  --     analysis = {
  --       useLibraryCodeForTypes = true,
  --       diagnosticSeverityOverrides = {
  --         reportGeneralTypeIssues = "none",
  --         reportOptionalMemberAccess = "none",
  --         reportOptionalSubscript = "none",
  --         reportPrivateImportUsage = "none",
  --       },
  --     },
  --   },
  -- },
  -- pylsp = {
  --   flags = {
  --     debounce_text_changes = 200,
  --   },
  --   settings = {
  --     pylsp = {
  --       plugins = {
  --         black = { enabled = false },
  --         autopep8 = { enabled = false },
  --         yapf = { enabled = false },
  --         -- linter options
  --         pylint = { enabled = false },
  --         pyflakes = { enabled = false },
  --         pycodestyle = { enabled = false },
  --         -- type checker
  --         pylsp_mypy = { enabled = false },
  --         -- auto-completion options
  --         jedi_completion = { fuzzy = true },
  --         jedi_hover = { enabled = true },
  --         jedi_references = { enabled = true },
  --         jedi_signature_help = { enabled = true },
  --         jedi_symbols = {
  --           enabled = true,
  --           all_scopes = true
  --         },
  --         -- import sorting
  --         pyls_isort = { enabled = false },
  --
  --       }
  --     }
  --   }
  -- },
  clangd = {
    cmd = {
      "/usr/bin/clangd",
      "--background-index",
      "-j=16",
      "--clang-tidy",
      "--completion-style=detailed",
      "--header-insertion=never",
      -- "--offset-encoding=utf-16", --temporary fix for null-ls
      "--pch-storage=memory"
    }
  }
}

M.setup = {
  -- clangd = function(_, opts)
  --   local wk = require("which-key")
  --
  --   wk.add({
  --     { "gh", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch source header" },
  --   })
  --
  --   require("clangd_extensions").setup({
  --     server = opts,
  --     extensions = {
  --       inlay_hints = {
  --         only_current_line = true,
  --       },
  --       role_icons = {
  --         type = "",
  --         declaration = "",
  --         expression = "",
  --         specifier = "",
  --         statement = "",
  --         ["template argument"] = "",
  --       },
  --
  --       kind_icons = {
  --         Compound = "",
  --         Recovery = "",
  --         TranslationUnit = "",
  --         PackExpansion = "",
  --         TemplateTypeParm = "",
  --         TemplateTemplateParm = "",
  --         TemplateParamObject = "",
  --       },
  --     },
  --   })
  --   return true
  -- end,
}

return M
