-- SPDX-License-Identifier: MIT

-- Trim trailing whitespace on save.
-- Skips prose filetypes where trailing spaces are meaningful (markdown hard
-- line breaks). Preserves cursor position, view, and the last search pattern.
local trim_skip_ft = {
  markdown = true,
  asciidoc = true,
  asciidoctor = true,
  text = true,
  gitcommit = true,
  diff = true,
  patch = true,
}
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('trim_trailing_ws', { clear = true }),
  callback = function()
    if vim.bo.filetype ~= '' and trim_skip_ft[vim.bo.filetype] then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Prevent Neovim from adding a trailing newline to the pack lockfile.
-- vim.pack writes the file without one; fixeol adds it back, causing a
-- perpetual one-line diff.
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('packlock_no_fixeol', { clear = true }),
  pattern = 'nvim-pack-lock.json',
  callback = function()
    vim.bo.fixeol = false
  end,
})

-- Auto-create parent directories when saving a new file.
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
  callback = function(ev)
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Restore last position
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('restore_cursor', { clear = true }),
  callback = function()
    local ok, mark = pcall(vim.api.nvim_buf_get_mark, 0, '"')
    if ok and mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Hybrid numbers
--
-- Treat certain buffers as "special" (never toggle numbers there)
local function is_special()
  local bt = vim.bo.buftype
  if bt == 'nofile' or bt == 'terminal' then
    return true
  end
  -- respect per-buffer opt-out flag
  return vim.b.hybrid_numbers_disable == true
end

-- When entering/focusing/leaving insert, etc: toggle hybrid numbers
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter', 'TermOpen' }, {
  group = vim.api.nvim_create_augroup('hybrid_numbers_on', { clear = true }),
  callback = function()
    if is_special() then
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      return
    end
    vim.opt_local.number = true
    vim.opt_local.relativenumber = (vim.api.nvim_get_mode().mode ~= 'i')
  end,
})

vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave', 'TermClose' }, {
  group = vim.api.nvim_create_augroup('hybrid_numbers_off', { clear = true }),
  callback = function()
    if is_special() then
      return
    end
    vim.opt_local.number = true
    vim.opt_local.relativenumber = false
  end,
})

-- Yank flash (built-in, replaces tiny-glimmer.nvim)
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = 'IncSearch', timeout = 200, on_visual = true })
  end,
})

-- Dynamic colorcolumn — only shown when a line exceeds the limit
--
-- The column width is read from the attached LSP server (e.g. ruff
-- lineLength) and falls back to vim.b.colorcolumn_limit or 88.
local cc_group = vim.api.nvim_create_augroup('dynamic_colorcolumn', { clear = true })

--- Resolve the line-length limit for the current buffer.
--- Priority: buffer-local override > LSP server setting > 88.
local function get_line_limit(bufnr)
  bufnr = bufnr or 0
  -- Buffer-local override (user can `:let b:colorcolumn_limit = 120`)
  local override = vim.b[bufnr].colorcolumn_limit
  if override then
    return override
  end

  -- Query attached LSP clients for a line-length setting
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    local s = client.settings or {}
    -- ruff: settings.lineLength
    if s.lineLength then
      return s.lineLength
    end
    -- ruff (nested): settings.ruff.lineLength
    if s.ruff and s.ruff.lineLength then
      return s.ruff.lineLength
    end
    -- pylsp / pycodestyle: settings.pylsp.plugins.pycodestyle.maxLineLength
    local pylsp = s.pylsp
    if pylsp and pylsp.plugins and pylsp.plugins.pycodestyle then
      local ml = pylsp.plugins.pycodestyle.maxLineLength
      if ml then
        return ml
      end
    end
    -- rust_analyzer doesn't expose a line width, but rustfmt uses
    -- max_width; not typically available via LSP settings.
  end

  return 88
end

--- Build skip-set from user config (vim.g.colorcolumn_skip_filetypes).
local function cc_skip_ft()
  local set = {}
  for _, ft in ipairs(vim.g.colorcolumn_skip_filetypes or {}) do
    set[ft] = true
  end
  return set
end

--- Check visible lines and toggle colorcolumn accordingly.
local function update_colorcolumn()
  if vim.bo.buftype ~= '' then
    return
  end -- skip special buffers
  if cc_skip_ft()[vim.bo.filetype] then
    if vim.wo.colorcolumn ~= '' then
      vim.wo.colorcolumn = ''
    end
    return
  end
  local limit = get_line_limit(0)
  local top = vim.fn.line('w0')
  local bot = vim.fn.line('w$')
  local exceeded = false
  for lnum = top, bot do
    local line = vim.fn.getline(lnum)
    if vim.fn.strdisplaywidth(line) > limit then
      exceeded = true
      break
    end
  end
  local want = exceeded and tostring(limit) or ''
  if vim.wo.colorcolumn ~= want then
    vim.wo.colorcolumn = want
  end
end

-- Refresh only on events that change which lines are visible or their content
-- — deliberately NOT CursorMoved/CursorMovedI, which would re-scan every
-- visible line on each cursor motion (needless cost for a cosmetic hint).
-- BufWinEnter covers the initial evaluation when a buffer is first displayed.
vim.api.nvim_create_autocmd({ 'TextChanged', 'WinScrolled', 'InsertLeave', 'BufWinEnter' }, {
  group = cc_group,
  callback = update_colorcolumn,
})

-- Re-evaluate when an LSP server attaches (line limit may change)
vim.api.nvim_create_autocmd('LspAttach', {
  group = cc_group,
  callback = function()
    -- Small delay so the server's settings are fully populated
    vim.defer_fn(update_colorcolumn, 100)
  end,
})

-- NOTE: venv/PATH management is handled at the shell level (mise/direnv).
-- The previous DirChanged autocmd auto-ran `uv sync` on cd (unattended install)
-- and prepended venv/bin to PATH on every DirChanged without dedup, stacking
-- duplicate PATH entries for the whole nvim process. Removed intentionally.
