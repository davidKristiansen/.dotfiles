-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

local M = {}

-- Pick a single client that supports `method` for this buffer
local function pick_client(bufnr, method)
  local best
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.supports_method and c:supports_method(method) then
      best = c
      break
    end
  end
  -- Fallback: just take first client (rare)
  if not best then
    best = vim.lsp.get_clients({ bufnr = bufnr })[1]
  end
  return best
end

-- Normalize LSP results to a flat list of Locations
local function normalize_locations(result)
  if not result then return {} end
  local list = result
  if not vim.tbl_islist(result) then
    list = { result }
  end
  local out = {}
  for _, loc in ipairs(list) do
    if loc.targetUri then
      table.insert(out, { uri = loc.targetUri, range = loc.targetRange })
    else
      table.insert(out, loc)
    end
  end
  return out
end

local function jump_or_list_locs(locs, title, encoding)
  if #locs == 0 then
    vim.notify("[LSP] no results for " .. title)
    return
  end
  if #locs == 1 then
    vim.lsp.util.jump_to_location(locs[1], encoding) -- explicit encoding
    return
  end
  local items = vim.lsp.util.locations_to_items(locs, encoding) -- explicit encoding
  vim.fn.setqflist({}, " ", { title = title, items = items })
  vim.cmd.copen()
end

-- Generic request -> prefer fzf-lua, else directed single-client request
local function lsp_pick(method, fzf_fn_name, title)
  local bufnr = vim.api.nvim_get_current_buf()

  -- Prefer fzf-lua if installed; it handles its own requests/UI
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf[fzf_fn_name] then
    fzf[fzf_fn_name]()
    return
  end

  local client = pick_client(bufnr, method)
  if not client then
    vim.notify("[LSP] no client for " .. method, vim.log.levels.WARN)
    return
  end

  -- Pass explicit position encoding (fixes the warnings)
  local posparams = vim.lsp.util.make_position_params(0, client.offset_encoding)

  client.request(method, posparams, function(err, result, ctx)
    if err then
      vim.notify(("[LSP] %s error: %s"):format(method, err.message or err), vim.log.levels.WARN)
      return
    end
    local locs = normalize_locations(result)
    jump_or_list_locs(locs, title, client.offset_encoding)
  end, bufnr)
end

function M.definitions() lsp_pick("textDocument/definition", "lsp_definitions", "LSP Definitions") end

function M.declarations() lsp_pick("textDocument/declaration", "lsp_declarations", "LSP Declarations") end

function M.implementations() lsp_pick("textDocument/implementation", "lsp_implementations", "LSP Implementations") end

function M.type_definitions() lsp_pick("textDocument/typeDefinition", "lsp_typedefs", "LSP Type Definitions") end

function M.references() lsp_pick("textDocument/references", "lsp_references", "LSP References") end

return M
