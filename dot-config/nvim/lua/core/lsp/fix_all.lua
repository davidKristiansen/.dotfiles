-- SPDX-License-Identifier: MIT
-- File: lua/core/lsp/fix_all.lua
-- Deterministic LSP FixAll + QuickFix-all (Ruff/ESLint/typos-lsp/etc.) + Format-on-save pipeline.

local M = {}

-- ── prefs ──────────────────────────────────────────────────────────────────────
local FIXALL_KINDS = {
  'source.fixAll.ruff',
  'source.fixAll',
  'source.organizeImports.ruff',
  'source.organizeImports',
  'quickfix',
}

local defaults = {
  enable_on_save = false, -- buffer default; can toggle per buffer
  save_timeout_ms = 800, -- sync wait per client (ms)
  create_commands = true, -- :LspFixAll / :LspFixAllToggle
  notify = true, -- vim.notify feedback
}

-- ── helpers ────────────────────────────────────────────────────────────────────
local function notify(msg, level)
  if defaults.notify then
    vim.notify(msg, level or vim.log.levels.INFO)
  end
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

--- Is this a source-level (bulk) action?
local function is_source_action(kind)
  return kind and kind:match('^source%.') ~= nil
end

--- Score source actions to pick the best one per client.
local function score_source_action(kind, title)
  title = (title or ''):lower()
  if kind == 'source.fixAll.ruff' or title:find('ruff', 1, true) then
    return 100
  end
  if kind and kind:match('^source%.fixAll') then
    return 90
  end
  if kind == 'source.organizeImports.ruff' then
    return 80
  end
  if kind == 'source.organizeImports' then
    return 70
  end
  return 0
end

--- Resolve an action that lacks edit/command.
local function resolve_action(bufnr, action, timeout)
  if action.edit or action.command then
    return action
  end
  local resolved_tbl = vim.lsp.buf_request_sync(bufnr, 'codeAction/resolve', action, timeout)
  if resolved_tbl then
    for _, r in pairs(resolved_tbl) do
      if r and r.result then
        return r.result
      end
    end
  end
  return action
end

--- Apply a single resolved action via the originating client.
local function apply_action(bufnr, action, client)
  local applied = false
  if action.edit and client then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    applied = true
  end
  if action.command and client then
    client:exec_cmd(action.command, { bufnr = bufnr })
    applied = true
  end
  return applied
end

-- ── core ───────────────────────────────────────────────────────────────────────
--- Run FixAll: applies the best source action + all quickfix actions per client.
function M.run(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local timeout = (opts and opts.timeout_ms) or defaults.save_timeout_ms
  local any_applied = false

  local win = pick_window_for_buf(bufnr)
  local first = (vim.lsp.get_clients({ bufnr = bufnr }) or {})[1]
  local pos_enc = (first and first.offset_encoding) or 'utf-16'

  local params = vim.lsp.util.make_range_params(win, pos_enc)
  -- Include real diagnostics so servers like typos-lsp (which derive
  -- code actions from their own diagnostics) can find them.
  local lsp_diags = vim.lsp.diagnostic.from(vim.diagnostic.get(bufnr))
  params.context = { only = FIXALL_KINDS, diagnostics = lsp_diags }

  local responses = vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, timeout)
  if not responses then
    return false
  end

  for client_id, resp in pairs(responses) do
    local actions = resp and resp.result
    if actions and #actions > 0 then
      local client = vim.lsp.get_client_by_id(client_id)

      -- Partition into source actions and quickfix actions
      local best_source, best_score = nil, -1
      local quickfixes = {}

      for _, a in ipairs(actions) do
        local kind = a.kind or ''
        if is_source_action(kind) then
          local s = score_source_action(kind, a.title)
          if s > best_score then
            best_source, best_score = a, s
          end
        else
          -- quickfix or other non-source actions
          quickfixes[#quickfixes + 1] = a
        end
      end

      -- Apply best source action (e.g. Ruff fixAll)
      if best_source then
        best_source = resolve_action(bufnr, best_source, timeout)
        if apply_action(bufnr, best_source, client) then
          any_applied = true
        end
      end

      -- Apply all quickfix actions that carry edits (e.g. typos-lsp corrections).
      -- Skip command-only actions (e.g. "Ignore in project") to avoid
      -- broadcasting unknown commands to unrelated LSP clients.
      for _, qf in ipairs(quickfixes) do
        if qf.edit or not qf.command then
          qf = resolve_action(bufnr, qf, timeout)
          if apply_action(bufnr, qf, client) then
            any_applied = true
          end
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
  notify(('FixAll on save: %s'):format(vim.b[bufnr].fix_all_on_save and 'ON' or 'OFF'))
end

-- does any attached client support format?
local function supports_format(bufnr)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.supports_method and c:supports_method('textDocument/formatting') then
      return true
    end
  end
  return false
end

-- unified save pipeline: FixAll → Format
function M.pipeline(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- FixAll first (only if enabled)
  if vim.b[bufnr].fix_all_on_save or vim.g.fix_all_on_save then
    M.run(bufnr)
  end

  -- Then format (global toggle + client support + disable for C files)
  local is_c_file = vim.bo[bufnr].filetype == 'c'
  if not is_c_file and vim.g.format_on_save and supports_format(bufnr) then
    vim.lsp.buf.format({ async = false, bufnr = bufnr })
  end
end

-- attach per buffer: commands and the single BufWritePre hook
function M.attach(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.b[bufnr].fix_all_on_save == nil then
    -- Disable fix-all for C files by default
    if vim.bo[bufnr].filetype == 'c' then
      vim.b[bufnr].fix_all_on_save = false
    else
      vim.b[bufnr].fix_all_on_save = defaults.enable_on_save
    end
  end

  if defaults.create_commands then
    vim.api.nvim_buf_create_user_command(bufnr, 'LspFixAll', function()
      local ok = M.run(bufnr)
      if ok then
        notify('FixAll applied')
      else
        notify('No FixAll actions', vim.log.levels.DEBUG)
      end
    end, { desc = 'LSP: Fix all (Ruff/ESLint/typos-lsp/etc.)' })

    vim.api.nvim_buf_create_user_command(bufnr, 'LspFixAllToggle', function()
      M.toggle_on_save(bufnr)
    end, { desc = 'Toggle FixAll on save (buffer)' })
  end

  local grp = vim.api.nvim_create_augroup(('LspSavePipeline_%d'):format(bufnr), { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = grp,
    buffer = bufnr,
    callback = function()
      M.pipeline(bufnr)
    end,
    desc = 'Save pipeline: FixAll → Format',
  })
end

-- public setup: installs attach on LspAttach
function M.setup(opts)
  defaults = vim.tbl_deep_extend('force', defaults, opts or {})
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('FixAllAttach', { clear = true }),
    callback = function(args)
      M.attach(args.buf)
    end,
  })
end

return M
