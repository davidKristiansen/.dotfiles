-- lua/plugins/mason_lspconfig.lua
-- SPDX-License-Identifier: MIT
-- Updated to avoid deprecated root require('lspconfig') usage (see :help lspconfig-nvim-0.11)
-- We now load individual server modules (require('lspconfig.SERVER')) so the new API
-- can be adopted progressively without triggering the deprecation warning.

local M = {}

-- Try to detect whether the new ts_ls server exists without requiring the root module.
local function detect_ts_server()
  local ok_tsls = pcall(require, "lspconfig.ts_ls")
  if ok_tsls then return "ts_ls" end
  -- Fallback name
  return "tsserver"
end

function M.setup()
  local ok_bridge, bridge = pcall(require, "mason-lspconfig")
  if not ok_bridge then return end

  local has_new_api = vim.lsp and vim.lsp.config and vim.lsp.enable
  local TS = has_new_api and (vim.lsp.config['ts_ls'] and 'ts_ls' or 'tsserver') or detect_ts_server()

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
      -- settings = { diagnosticSeverity = "Hint" }, -- Example to lower noise
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

  -- If on Neovim 0.11+ use the new vim.lsp.config data-only interface and avoid any lspconfig.* requires.
  if has_new_api then
    for _, server in ipairs(ENSURE) do
      local overrides = SERVER_SETTINGS[server]
      pcall(function()
        if overrides then
          vim.lsp.config(server, overrides)
        else
          _ = vim.lsp.config(server) -- ensure default exists
        end
        vim.lsp.enable(server)
      end)
    end
    return
  end

  -- Helper that sets up a server module WITHOUT using the deprecated root module.
  local function setup_server(server, conf)
    -- Try loading the individual server module
    local ok_mod, mod = pcall(require, "lspconfig." .. server)
    if not ok_mod then
      return -- server module not available yet
    end

    -- Preferred: if module exposes setup (older style but allowed without root require)
    if type(mod.setup) == "function" then
      mod.setup(conf)
      return
    end

    -- Fallback: try to start manually if we can infer defaults
    if vim.lsp and vim.lsp.start and mod.document_config and mod.document_config.default_config then
      local base = mod.document_config.default_config
      local manual = vim.tbl_deep_extend("force", base, conf or {})
      manual.name = manual.name or server
      vim.lsp.start(manual)
    end
  end

  bridge.setup({
    ensure_installed = ENSURE,
    automatic_installation = true,
    handlers = {
      function(server)
        local conf = SERVER_SETTINGS[server] or {}
        setup_server(server, conf)
      end,
    },
  })

  -- Back-compat: older mason-lspconfig exposed setup_handlers instead
  if type(bridge.setup_handlers) == "function" then
    bridge.setup_handlers({
      function(server)
        local conf = SERVER_SETTINGS[server] or {}
        setup_server(server, conf)
      end,
    })
  end
end

return M
