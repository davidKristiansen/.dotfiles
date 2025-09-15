-- lua/plugins/mason_lspconfig.lua
-- SPDX-License-Identifier: MIT
local M = {}

-- Resolve the TS server name across lspconfig versions (ts_ls vs tsserver)
local function detect_ts_server()
  local ok, lspconfig = pcall(require, "lspconfig")
  if not ok then return "tsserver" end
  if type(lspconfig.ts_ls) == "table" then return "ts_ls" end
  return "tsserver"
end

function M.setup()
  local ok_bridge, bridge = pcall(require, "mason-lspconfig")
  if not ok_bridge then return end
  local ok_lsp, lspconfig = pcall(require, "lspconfig")
  if not ok_lsp then return end

  local TS = detect_ts_server()

  -- Ensure these are installed by Mason
  local ENSURE = {
    "lua_ls",
    -- "ruff",                   -- Python linter LSP (diagnostics, code actions)
    -- "basedpyright",           -- Python linter LSP (diagnostics, code actions)
    "typos_lsp",              -- Spelling/typos across many filetypes
    "clangd",
    "docker_language_server", -- Dockerfile
    "taplo",                  -- TOML
    "yamlls",                 -- YAML
    "bashls",                 -- Bash; we’ll extend to zsh filetype
    "jsonls",                 -- JSON
    TS,                       -- ts_ls or tsserver
  }

  -- Per-server settings (keep attach/keymaps in your LspAttach)
  local SERVER_SETTINGS = {
    docker_language_server = {},
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace   = { checkThirdParty = false },
          telemetry   = { enable = false },
        },
      },
    },

    -- NOTE: ruff_lsp is *not* a full Python language server; pair it with pyright
    -- later if you want definitions/hover/etc. For now you asked just ruff.
    ruff = {
      init_options = {
        settings = {
          args = {}, -- e.g. { "--line-length", "100" }
        },
      },
    },

    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "basic", -- can also be "strict"
        diagnosticSeverityOverrides = {
          reportUnusedImport = "none",
          reportUnusedVariable = "none",
          reportUndefinedVariable = "none", -- optional if Ruff F821 is enabled
        },
      },
    },


    ty = {},

    typos_lsp = {
      -- Example: lower noise if you like
      -- settings = { diagnosticSeverity = "Hint" },
    },

    clangd = {
      cmd = { "clangd", "--background-index", "--clang-tidy" },
      init_options = { clangdFileStatus = true },
    },

    taplo = {}, -- TOML (formatting, schema)

    yamlls = {
      settings = {
        yaml = {
          keyOrdering = false,
          -- schemas = { kubernetes = "*.yaml" }, -- add if you want
        },
      },
    },

    bashls = {
      filetypes = { "sh", "bash", "zsh" }, -- extend to zsh files too
    },

    jsonls = {
      settings = {
        json = {
          validate = { enable = true },
          -- schemas = require("schemastore").json.schemas(), -- if you add schemastore
        },
      },
    },

    ts_ls = {
      settings = {
        completions = { completeFunctionCalls = true },
      },
    },

    tsserver = {
      settings = {
        completions = { completeFunctionCalls = true },
      },
    },
  }

  bridge.setup({
    ensure_installed = ENSURE,
    automatic_installation = true,
    handlers = {
      function(server)
        local conf = SERVER_SETTINGS[server] or {}
        lspconfig[server].setup(conf)
      end,
    },
  })

  -- Back-compat: older mason-lspconfig exposed setup_handlers instead
  if type(bridge.setup_handlers) == "function" then
    bridge.setup_handlers({
      function(server)
        local conf = SERVER_SETTINGS[server] or {}
        lspconfig[server].setup(conf)
      end,
    })
  end
end

return M
