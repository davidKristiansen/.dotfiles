-- lua/plugins/lsp/settings.lua
-- SPDX-License-Identifier: MIT

local M = {}

-- Map Mason package IDs -> lspconfig server names
local MASON_TO_LSP = {
  ["lua_ls"] = "lua_ls",
  ["typos_lsp"] = "typos_lsp",
  ["clangd"] = "clangd",
  ["taplo"] = "taplo", -- TOML
  ["yamlls"] = "yamlls",
  ["yaml-language-server"] = "yamlls",
  ["bashls"] = "bashls",
  ["bash-language-server"] = "bashls",
  ["jsonls"] = "jsonls",
  ["docker_language_server"] = "dockerls",
  ["tsserver"] = "tsserver",
  ["ts_ls"] = "ts_ls",
  ["copilot-language-server"] = "copilot",
  ["ruff"] = "ruff", -- Ruff LSP
  ["basedpyright"] = "basedpyright",
}

local function detect_ts_server()
  local ok_tsls = pcall(require, "lspconfig.ts_ls")
  if ok_tsls then return "ts_ls" end
  return "tsserver"
end

local function setup_lsp_servers()
  local ok_bridge, bridge = pcall(require, "mason-lspconfig")
  if not ok_bridge then return end

  local has_new_api = vim.lsp and vim.lsp.config and vim.lsp.enable
  local TS = has_new_api and (vim.lsp.config["ts_ls"] and "ts_ls" or "tsserver") or detect_ts_server()

  -- Mason package IDs to install
  local ENSURE = {
    "lua_ls",
    "typos_lsp",
    "clangd",
    "docker_language_server",
    "taplo", -- TOML
    "yamlls", -- YAML
    "bashls", -- Bash/Zsh
    "jsonls", -- JSON
    "copilot-language-server",
    "ruff", -- Ruff diagnostics + code actions
    "basedpyright", -- Python types
    TS,
  }

  if has_new_api then
    bridge.setup({ ensure_installed = ENSURE, automatic_installation = true })

    -- Enable LSP servers by lspconfig ids derived via mapping
    local to_enable = {}
    for _, pkg in ipairs(ENSURE) do
      local lsp = MASON_TO_LSP[pkg] or pkg
      to_enable[lsp] = true
    end

    require('lsp').enable_servers(vim.tbl_keys(to_enable))
    return
  end

  -- Legacy path (pre-0.11) using lspconfig modules directly
  local function setup_server(server, conf)
    local ok_mod, mod = pcall(require, "lspconfig." .. server)
    if not ok_mod then return end
    if type(mod.setup) == "function" then
      mod.setup(conf)
      return
    end
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
      function(pkg)
        local lsp = MASON_TO_LSP[pkg] or pkg
        local conf = require("lsp").get_config(lsp) or {}
        setup_server(lsp, conf)
      end,
    },
  })
end

local function setup_lsp_attach_hooks()
  require('lsp').setup_attach_autocmd()
end

function M.setup()
  setup_lsp_attach_hooks()
  setup_lsp_servers()
end

return M
