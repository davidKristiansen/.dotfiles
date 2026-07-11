-- lua/core/lsp/format.lua
-- SPDX-License-Identifier: MIT
-- LSP formatting in three granularities — line, changed hunks, buffer — plus
-- a hunk-scoped format-on-save pipeline. Scoping saves to git-changed hunks
-- (via gitsigns) means code you didn't touch is never reformatted, so
-- format-on-save stays safe even in third-party checkouts.

local M = {}

local SAVE_TIMEOUT_MS = 800

local Methods = vim.lsp.protocol.Methods

---@param bufnr integer
---@param method string
---@return boolean
local function supports(bufnr, method)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c:supports_method(method, bufnr) then
      return true
    end
  end
  return false
end

--- Format an inclusive 1-indexed line range.
---@param bufnr integer
---@param start_line integer
---@param end_line integer
---@param opts table? passed through to vim.lsp.buf.format
local function format_lines(bufnr, start_line, end_line, opts)
  local last = vim.api.nvim_buf_get_lines(bufnr, end_line - 1, end_line, false)[1] or ''
  vim.lsp.buf.format(vim.tbl_extend('force', {
    bufnr = bufnr,
    range = {
      ['start'] = { start_line, 0 },
      ['end'] = { end_line, #last },
    },
  }, opts or {}))
end

--- Changed-line ranges (1-indexed, inclusive) from gitsigns hunks.
--- nil = no hunk information available (gitsigns absent or unattached);
--- {}  = attached and clean.
---@param bufnr integer
---@return integer[][]?
local function hunk_ranges(bufnr)
  local ok, gitsigns = pcall(require, 'gitsigns')
  if not ok then
    return nil
  end
  local hunks = gitsigns.get_hunks(bufnr)
  if not hunks then
    return nil
  end
  local ranges = {}
  for _, h in ipairs(hunks) do
    -- Pure deletions have added.count == 0: nothing in the buffer to format.
    if h.added and h.added.count > 0 then
      ranges[#ranges + 1] = { h.added.start, h.added.start + h.added.count - 1 }
    end
  end
  return ranges
end

--- Does this buffer's file have a git baseline to diff against?
---@param bufnr integer
---@return boolean
local function has_git_baseline(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' or not vim.fs.root(name, '.git') then
    return false
  end
  local out = vim.system({ 'git', '-C', vim.fs.dirname(name), 'ls-files', '--error-unmatch', '--', name }):wait()
  return out.code == 0
end

-- ── public API ─────────────────────────────────────────────────────────────

---@param bufnr integer?
---@param opts table?
function M.buffer(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.lsp.buf.format(vim.tbl_extend('force', { bufnr = bufnr, async = true }, opts or {}))
end

--- Format the cursor line.
function M.line()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  format_lines(bufnr, lnum, lnum, { async = false })
end

--- Format the visual selection (call from a visual-mode mapping).
function M.selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local s = vim.fn.getpos('v')[2]
  local e = vim.fn.getpos('.')[2]
  if s > e then
    s, e = e, s
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  format_lines(bufnr, s, e, { async = false })
end

--- Format only git-changed hunks. Untracked files (no baseline) count as
--- fully changed; a tracked file with no hunk info is skipped, never guessed.
---@param bufnr integer?
---@param opts table?
function M.changed(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  opts = opts or { async = false }

  local ranges = hunk_ranges(bufnr)

  if ranges == nil then
    if has_git_baseline(bufnr) then
      return -- baseline exists but no hunk info: don't guess
    end
    if supports(bufnr, Methods.textDocument_formatting) then
      M.buffer(bufnr, opts) -- untracked / outside git: whole file is "changed"
    end
    return
  end

  if #ranges == 0 or not supports(bufnr, Methods.textDocument_rangeFormatting) then
    return
  end

  -- Bottom-up so earlier ranges' line numbers survive each edit.
  table.sort(ranges, function(a, b)
    return a[1] > b[1]
  end)
  for _, r in ipairs(ranges) do
    format_lines(bufnr, r[1], r[2], opts)
  end
end

-- ── format on save ──────────────────────────────────────────────────────────

---@param bufnr integer
---@return boolean
function M.on_save_enabled(bufnr)
  local b = vim.b[bufnr].format_on_save
  if b ~= nil then
    return b
  end
  return vim.g.format_on_save == true
end

---@param bufnr integer?
function M.toggle_on_save_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.b[bufnr].format_on_save = not M.on_save_enabled(bufnr)
  vim.notify(('Format on save (buffer): %s'):format(vim.b[bufnr].format_on_save and 'ON' or 'OFF'))
end

function M.toggle_on_save_global()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify(('Format on save (global): %s'):format(vim.g.format_on_save and 'ON' or 'OFF'))
end

function M.setup()
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('LspFormatOnSave', { clear = true }),
    desc = 'Format changed hunks on save',
    callback = function(args)
      if not M.on_save_enabled(args.buf) then
        return
      end
      -- A failed format must never block the write.
      pcall(M.changed, args.buf, { async = false, timeout_ms = SAVE_TIMEOUT_MS })
    end,
  })
end

return M
