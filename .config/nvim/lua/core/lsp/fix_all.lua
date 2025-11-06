-- SPDX-License-Identifier: MIT
-- File: lua/core/lsp/fix_all.lua
-- Deterministic LSP FixAll (Ruff/ESLint/etc.) + Format-on-save pipeline.

local M = {}

-- ── prefs ──────────────────────────────────────────────────────────────────────
local FIXALL_KINDS = {
  "source.fixAll.ruff",
  "source.fixAll",
  "source.organizeImports.ruff",
  "source.organizeImports",
}

local defaults = {
  enable_on_save = false,  -- buffer default; can toggle per buffer
  save_timeout_ms = 800,   -- sync wait per client (ms)
  filetypes = nil,         -- e.g. { "python" } to limit FixAll; nil = all
  create_commands = true,  -- :LspFixAll / :LspFixAllToggle
  create_mappings = false, -- set true to add default keymaps
  mapping_run = "<leader>fa",
  mapping_toggle = "<leader>ta",
  notify = true, -- vim.notify feedback
}

-- ── helpers ────────────────────────────────────────────────────────────────────
local function notify(msg, level)
  if defaults.notify then vim.notify(msg, level or vim.log.levels.INFO) end
end

local function filetype_allowed(bufnr)
  if not defaults.filetypes or #defaults.filetypes == 0 then return true end
  local ft = vim.bo[bufnr].filetype
  for _, x in ipairs(defaults.filetypes) do
    if x == ft then return true end
  end
  return false
end

local function pick_window_for_buf(bufnr)
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
    return win
  end
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == bufnr then
      return w
    end
  end
  return vim.api.nvim_get_current_win()
end

local function score_action(kind, title)
  title = (title or ""):lower()
  if kind == "source.fixAll.ruff" or title:find("ruff", 1, true) then return 100 end
  if kind and kind:match("^source%.fixAll") then return 90 end
  if kind == "source.organizeImports.ruff" then return 80 end
  if kind == "source.organizeImports" then return 70 end
  return 0
end

local function pick_best(actions)
  local best, best_s = nil, -1
  for _, a in ipairs(actions or {}) do
    local s = score_action(a.kind or "", a.title)
    if s > best_s then best, best_s = a, s end
  end
  return best
end

-- ── core: FixAll (sync; per-client; deterministic) ─────────────────────────────
function M.run(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not filetype_allowed(bufnr) then return false end

  local timeout = (opts and opts.timeout_ms) or defaults.save_timeout_ms
  local any_applied = false

  -- choose a valid window + a baseline position encoding
  local win = pick_window_for_buf(bufnr)
  local first = (vim.lsp.get_clients({ bufnr = bufnr }) or {})[1]
  local pos_enc = (first and first.offset_encoding) or "utf-16"

  local params = vim.lsp.util.make_range_params(win, pos_enc)
  params.context = { only = FIXALL_KINDS, diagnostics = {} }

  -- ask ALL clients synchronously (non-deprecated)
  local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, timeout)
  if not responses then return false end

  for client_id, resp in pairs(responses) do
    local actions = resp and resp.result
    if actions and #actions > 0 then
      local client = vim.lsp.get_client_by_id(client_id)
      local action = pick_best(actions)
      if action then
        -- if action lacks edit/command, try resolving via buf_request_sync (non-deprecated)
        if not action.edit and not action.command then
          local resolved_tbl = vim.lsp.buf_request_sync(bufnr, "codeAction/resolve", action, timeout)
          if resolved_tbl then
            for _, r in pairs(resolved_tbl) do
              if r and r.result then
                action = r.result
                break
              end
            end
          end
        end

        -- apply edit (with the *originating* client's offset encoding), then command
        if action.edit and client then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
          any_applied = true
        end
        if action.command then
          vim.lsp.buf.execute_command(action.command)
          any_applied = true
        end
      end
    end
  end

  return any_applied
end

-- toggle per buffer
function M.toggle_on_save(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.b[bufnr].fix_all_on_save = not vim.b[bufnr].fix_all_on_save
  notify(("FixAll on save: %s"):format(vim.b[bufnr].fix_all_on_save and "ON" or "OFF"))
end

-- does any attached client support format?
local function supports_format(bufnr)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.supports_method and c:supports_method("textDocument/formatting") then
      return true
    end
  end
  return false
end

-- unified save pipeline: FixAll → Format
function M.pipeline(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- FixAll first (only if enabled & allowed)
  if (vim.b[bufnr].fix_all_on_save or vim.g.fix_all_on_save) and filetype_allowed(bufnr) then
    M.run(bufnr)
  end

  -- Then format (global toggle + client support)
  if vim.g.format_on_save and supports_format(bufnr) then
    vim.lsp.buf.format({ async = false, bufnr = bufnr })
  end
end

-- attach per buffer: commands, mappings, and the single BufWritePre hook
function M.attach(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.b[bufnr].fix_all_on_save == nil then
    vim.b[bufnr].fix_all_on_save = defaults.enable_on_save
  end

  if defaults.create_commands then
    vim.api.nvim_buf_create_user_command(bufnr, "LspFixAll", function()
      local ok = M.run(bufnr)
      if ok then notify("FixAll applied") else notify("No FixAll actions", vim.log.levels.DEBUG) end
    end, { desc = "LSP: Fix all (Ruff/ESLint/etc.)" })

    vim.api.nvim_buf_create_user_command(bufnr, "LspFixAllToggle", function()
      M.toggle_on_save(bufnr)
    end, { desc = "Toggle FixAll on save (buffer)" })
  end

  if defaults.create_mappings then
    vim.keymap.set("n", defaults.mapping_run, function() M.run(bufnr) end,
      { buffer = bufnr, desc = "LSP FixAll now" })
    vim.keymap.set("n", defaults.mapping_toggle, function() M.toggle_on_save(bufnr) end,
      { buffer = bufnr, desc = "Toggle LSP FixAll on save" })
  end

  local grp = vim.api.nvim_create_augroup(("LspSavePipeline_%d"):format(bufnr), { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = grp,
    buffer = bufnr,
    callback = function() M.pipeline(bufnr) end,
    desc = "Save pipeline: FixAll → Format",
  })
end

-- public setup (optional convenience): installs attach on LspAttach
function M.setup(opts)
  defaults = vim.tbl_deep_extend("force", defaults, opts or {})
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("FixAllAttach", { clear = true }),
    callback = function(args)
      M.attach(args.buf)
    end,
  })
end

return M
