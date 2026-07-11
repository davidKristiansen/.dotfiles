-- lua/core/lsp/fix_all.lua
-- SPDX-License-Identifier: MIT
-- Deterministic LSP FixAll + QuickFix-all (Ruff/ESLint/typos-lsp/etc.).
-- Manual-only by design (<leader>cA / :LspFixAll): source-level fixes can be
-- destructive (e.g. removing "unused" imports/vars) and must never run on save.

local M = {}

local TIMEOUT_MS = 800

local FIXALL_KINDS = {
  'source.fixAll.ruff',
  'source.fixAll',
  'source.organizeImports.ruff',
  'source.organizeImports',
  'quickfix',
}

-- ── helpers ────────────────────────────────────────────────────────────────────
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

  local timeout = (opts and opts.timeout_ms) or TIMEOUT_MS
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
      local source_applied = false
      if best_source then
        best_source = resolve_action(bufnr, best_source, timeout)
        source_applied = apply_action(bufnr, best_source, client)
        any_applied = any_applied or source_applied
      end

      -- Apply all quickfix actions that carry edits (e.g. typos-lsp
      -- corrections) — but only from clients whose source action didn't run:
      -- a fixAll edit shifts the buffer, so this client's quickfix edits are
      -- both stale and redundant with it. Skip command-only actions (e.g.
      -- "Ignore in project") to avoid broadcasting unknown commands to
      -- unrelated LSP clients.
      if not source_applied then
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
  end

  return any_applied
end

return M
