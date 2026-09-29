-- SPDX-License-Identifier: MIT
-- Buffer position to pull request comment target.
--
-- Two surfaces resolve a target. A diffview window states its side and its
-- revision, so the position is exact. A plain file buffer only matches the pull
-- request while it is unmodified and HEAD is the source commit of the pull
-- request, so it is checked before it is trusted.
local M = {}

local pr_module = require('utils.bitbucket.pr')

--- Repository-relative path of a file.
local function relative(root, path)
  local rel = vim.fs.relpath(root, path)
  if rel then
    return rel
  end
  return (path:gsub('^' .. vim.pesc(root) .. '/', ''))
end

--- Side of the diff shown in the current diffview window.
--- The layout API of diffview is internal, so a buffer name check backs it up.
local function diffview_side(layout, win)
  local sides = { a = 'FROM', b = 'TO' }
  for key, side in pairs(sides) do
    local window = layout[key]
    if window and window.id == win then
      return side
    end
  end
  if layout.c or layout.d then
    return nil, 'the merge layout has no pull request side to comment on'
  end
  return nil
end

local function diffview_target()
  local ok, lib = pcall(require, 'diffview.lib')
  if not ok then
    return nil
  end

  local view = lib.get_current_view()
  if not view or not view.cur_layout or not view.cur_entry then
    return nil
  end

  local win = vim.api.nvim_get_current_win()
  local side, err = diffview_side(view.cur_layout, win)
  if not side then
    if err then
      return nil, err
    end
    -- A window outside the layout, for example the file panel.
    side = vim.startswith(vim.api.nvim_buf_get_name(0), 'diffview://') and 'FROM' or 'TO'
  end

  local entry = view.cur_entry
  local line = vim.fn.line('.')
  return {
    path = entry.path,
    src_path = entry.oldpath or entry.path,
    line = line,
    text = vim.fn.getline(line),
    side = side,
    surface = 'diffview',
  }
end

local function plain_target(pr, opts)
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' or vim.bo.buftype ~= '' then
    return nil, 'the buffer holds no file of the repository'
  end
  if vim.bo.modified and not opts.force then
    return nil, 'the buffer is modified, so its line numbers differ from the pull request'
  end

  local head = pr_module.head()
  if not opts.force and pr.from_hash and head and head ~= pr.from_hash then
    return nil,
      ('HEAD %s is not the source commit %s of #%d, so line numbers can differ'):format(
        head:sub(1, 8),
        pr.from_hash:sub(1, 8),
        pr.id
      )
  end

  local location = require('utils.bitbucket.config').location()
  local path = relative(location and location.root or vim.fn.getcwd(), name)
  local line = vim.fn.line('.')
  return {
    path = path,
    src_path = path,
    line = line,
    text = vim.fn.getline(line),
    side = 'TO',
    surface = 'buffer',
  }
end

--- Target under the cursor.
--- @param pr table
--- @param opts table|nil { force }
--- @return table|nil target { path, src_path, line, side, surface }
--- @return string|nil error
function M.current(pr, opts)
  opts = opts or {}

  local target, err = diffview_target()
  if target then
    return target, nil
  end
  if err then
    return nil, err
  end
  return plain_target(pr, opts)
end

--- Line range of the last visual selection.
function M.selection()
  local first, last = vim.fn.line("'<"), vim.fn.line("'>")
  if first > last then
    first, last = last, first
  end
  return first, last
end

--- Quote a line range as a fenced block, so a comment on one line can still
--- point at several. The API anchors a comment to a single line.
function M.quote(bufnr, first, last)
  local lines = vim.api.nvim_buf_get_lines(bufnr, first - 1, last, false)
  local fence = '```'
  local out = { fence .. (vim.bo[bufnr].filetype or '') }
  vim.list_extend(out, lines)
  out[#out + 1] = fence
  return table.concat(out, '\n')
end

return M
