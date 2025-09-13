-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

-- modes: "off" | "save" | "ontype"
local M = {}
local mode = "ontype" -- default

-- ---- capabilities helper (optional but nice for picky servers) ----------
function M.capabilities(base)
  local caps = vim.tbl_deep_extend("force",
    vim.lsp.protocol.make_client_capabilities(),
    type(base) == "table" and base or {}
  )
  caps.textDocument = caps.textDocument or {}
  caps.textDocument.onTypeFormatting = { dynamicRegistration = true }

  local ok, cmp = pcall(require, "cmp_nvim_lsp")
  if ok then caps = cmp.default_capabilities(caps) end
  return caps
end

-- --- statusline helpers -----------------------------------------------------
function M.status_icon()
  local m = M.status and M.status() or "off"
  if m == "off" then return "󰅙 fmt-off" end
  if m == "save" then return "󰉼 save" end
  -- m == "ontype"
  return "󰬺 type"
end

-- Fire a status redraw when mode changes
local function _redraw_status()
  vim.schedule(function() vim.cmd("redrawstatus!") end)
end

-- ---- internals -----------------------------------------------------------
local SAVE_GROUP   = vim.api.nvim_create_augroup("lsp.format.save", { clear = true })
local ATTACH_GROUP = vim.api.nvim_create_augroup("lsp.format.attach", { clear = true })

local function set_on_type_enabled_for_buf(bufnr, enable)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.supports_method and c:supports_method("textDocument/onTypeFormatting") then
      vim.lsp.on_type_formatting.enable(enable, { client_id = c.id })
    end
  end
end

local function ensure_save_autocmd(bufnr)
  vim.api.nvim_clear_autocmds({ group = SAVE_GROUP, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = SAVE_GROUP,
    buffer = bufnr,
    desc = "[lsp/format] on-save (mode gated)",
    callback = function(args)
      if mode ~= "save" then return end
      vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 1000 })
    end,
  })
end

local function apply_mode_to_buf(bufnr)
  if not vim.api.nvim_buf_is_loaded(bufnr) then return end
  ensure_save_autocmd(bufnr)
  set_on_type_enabled_for_buf(bufnr, mode == "ontype")
end

local function apply_mode_to_all()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted then apply_mode_to_buf(b) end
  end
end

-- ---- public API ----------------------------------------------------------
function M.set(new_mode)
  if new_mode ~= "off" and new_mode ~= "save" and new_mode ~= "ontype" then
    vim.notify("[lsp/format] unknown mode: " .. tostring(new_mode), vim.log.levels.WARN)
    return
  end
  mode = new_mode
  apply_mode_to_all()
  vim.notify("[lsp/format] mode → " .. mode)
  _redraw_status()
end

function M.cycle()
  local next_mode = (mode == "off") and "save" or (mode == "save") and "ontype" or "off"
  M.set(next_mode)
end

function M.status() return mode end

-- ---- autocmds ------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = ATTACH_GROUP,
  callback = function(args)
    apply_mode_to_buf(args.buf)
  end,
})



-- ---- :Format command ------------------------------------------------------
-- :Format {off|save|ontype|status}
-- :Format (no arg) cycles off → save → ontype
vim.api.nvim_create_user_command("Format", function(cmd)
  local arg = cmd.args
  if arg == "" then
    return M.cycle()
  elseif arg == "status" then
    return vim.notify("[lsp/format] mode = " .. M.status())
  else
    return M.set(arg)
  end
end, {
  nargs = "?",
  complete = function(_, line)
    local opts = { "off", "save", "ontype", "status" }
    local pref = line:match("%s+(%S+)$") or ""
    local out = {}
    for _, o in ipairs(opts) do
      if o:find("^" .. vim.pesc(pref)) then table.insert(out, o) end
    end
    return out
  end,
})

return M
