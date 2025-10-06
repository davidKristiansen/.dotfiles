-- lua/lsp/init.lua
-- SPDX-License-Identifier: MIT
-- Aggregate & merge local server configs with default lspconfig definitions.

local M = {}

-- Pre-load on_attach so users can reference require('lsp').on_attach
local on_attach = require('lsp.on_attach')
M.on_attach = on_attach.setup

-- Cache for merged configs
local merged = {}

-- Helper to deep merge (force) two tables
local function merge_tbl(base, extra)
  if type(base) ~= 'table' then base = {} end
  if type(extra) ~= 'table' then return base end
  return vim.tbl_deep_extend('force', base, extra)
end

-- Load a local server config from:
--   lua/lsp/servers/<server>.lua
-- (legacy fallback removed)
local function load_local(server)
  local ok, conf = pcall(require, 'lsp.servers.' .. server)
  if ok and type(conf) == 'table' then
    return conf
  end
  return {}
end

-- Try get the default config from nvim-lspconfig (if installed / loaded)
local function load_lspconfig_default(server)
  local ok, mod = pcall(require, 'lspconfig.server_configurations.' .. server)
  if ok and type(mod) == 'table' then
    local def = mod.default_config or {}
    -- Copy to avoid mutating lspconfig's table
    return vim.deepcopy(def)
  end
  return {}
end

-- Public: get merged config (local overrides lspconfig defaults).
function M.get_config(server)
  if merged[server] ~= nil then
    return merged[server]
  end
  local base = load_lspconfig_default(server)
  local local_conf = load_local(server)
  local final = merge_tbl(base, local_conf)
  merged[server] = (next(final) ~= nil) and final or nil
  return merged[server]
end

-- Enable one or more servers (list of lspconfig ids)
function M.enable_servers(servers)
  if type(servers) ~= 'table' then return end
  local has_new_api = vim.lsp and vim.lsp.config and vim.lsp.enable
  for _, server in ipairs(servers) do
    local conf = M.get_config(server) or {}
    if has_new_api then
      if conf and next(conf) ~= nil then
        pcall(vim.lsp.config, server, conf)
      end
      pcall(vim.lsp.enable, server)
    else
      local ok_mod, mod = pcall(require, 'lspconfig.' .. server)
      if ok_mod then
        if type(mod.setup) == 'function' then
          mod.setup(conf)
        elseif vim.lsp and vim.lsp.start and mod.document_config and mod.document_config.default_config then
          local base = mod.document_config.default_config
          local manual = vim.tbl_deep_extend('force', base, conf or {})
          manual.name = manual.name or server
          vim.lsp.start(manual)
        end
      end
    end
  end
end

-- Setup autocmd for LspAttach (exposed for plugin layer to call once)
function M.setup_attach_autocmd()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_attach_core', { clear = true }),
    callback = M.on_attach,
  })
end

return M
