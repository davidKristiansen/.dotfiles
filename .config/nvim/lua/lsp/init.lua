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
--   lua/lsp/servers/<server>.lua  (new preferred location)
--   lua/lsp/<server>.lua          (backwards compatibility fallback)
local function load_local(server)
  local paths = { 'lsp.servers.' .. server, 'lsp.' .. server }
  for _, modname in ipairs(paths) do
    local ok, conf = pcall(require, modname)
    if ok and type(conf) == 'table' then
      return conf
    end
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

return M
