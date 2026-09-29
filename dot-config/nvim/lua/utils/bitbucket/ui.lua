-- SPDX-License-Identifier: MIT
-- Comment composer and inline thread display.
local M = {}

local config = require('utils.bitbucket.config')

local ns = vim.api.nvim_create_namespace('bitbucket_threads')

-- Rendered threads per buffer: extmark id to root comment.
local rendered = {}

local function define_highlights()
  local links = {
    BitbucketAuthor = 'Title',
    BitbucketBody = 'Comment',
    BitbucketSign = 'DiagnosticInfo',
    BitbucketResolved = 'NonText',
  }
  for name, target in pairs(links) do
    vim.api.nvim_set_hl(0, name, { link = target, default = true })
  end
end

--- Text of one comment as display lines.
local function comment_lines(comment, depth)
  local author = comment.author and comment.author.displayName or 'unknown'
  local prefix = string.rep('  ', depth)
  local marker = depth == 0 and config.opts.signs.thread or '↳'
  local resolved = comment.state == 'RESOLVED'
  local head = ('%s %s %s'):format(prefix, marker, author)
  if resolved then
    head = head .. ' (resolved)'
  end

  local lines = { { { head, resolved and 'BitbucketResolved' or 'BitbucketAuthor' } } }
  for line in vim.gsplit(comment.text or '', '\n', { plain = true }) do
    lines[#lines + 1] = { { prefix .. '   ' .. line, 'BitbucketBody' } }
  end
  for _, reply in ipairs(comment.comments or {}) do
    vim.list_extend(lines, comment_lines(reply, depth + 1))
  end
  return lines
end

local function truncate(lines)
  local limit = config.opts.max_lines
  if limit <= 0 or #lines <= limit then
    return lines
  end
  local out = vim.list_slice(lines, 1, limit)
  out[#out + 1] = { { ('   … %d more lines'):format(#lines - limit), 'BitbucketResolved' } }
  return out
end

--- Place the marks of a buffer from its stored state. A sign marks every line
--- that carries a thread. The comment text is virtual lines above the next line,
--- and it is the only part that hides.
local function place(bufnr)
  local state = rendered[bufnr]
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local total = vim.api.nvim_buf_line_count(bufnr)
  local marks, shown = {}, 0

  for _, thread in ipairs(state.threads) do
    local anchor = thread.anchor
    if anchor and anchor.line and anchor.fileType == state.side and not anchor.orphaned then
      local row = math.min(anchor.line, total) - 1
      local resolved = thread.state == 'RESOLVED'
      local id = vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
        sign_text = resolved and config.opts.signs.resolved or config.opts.signs.thread,
        sign_hl_group = resolved and 'BitbucketResolved' or 'BitbucketSign',
        virt_lines = state.show_text and truncate(comment_lines(thread, 0)) or nil,
        virt_lines_above = false,
      })
      marks[id] = thread
      shown = shown + 1
    end
  end

  state.marks = marks
  return shown
end

--- Draw the threads of one file side into a buffer.
--- @param bufnr number
--- @param side string 'TO' or 'FROM'
--- @param threads table[] root comments
--- @param opts table|nil { show_text } defaults to what the buffer showed before
function M.render(bufnr, side, threads, opts)
  opts = opts or {}
  define_highlights()

  local previous = rendered[bufnr]
  local show_text = opts.show_text
  if show_text == nil then
    show_text = previous and previous.show_text
  end
  if show_text == nil then
    show_text = true
  end

  rendered[bufnr] = { side = side, threads = threads, show_text = show_text }
  return place(bufnr)
end

--- Show or hide the comment text. The signs stay, so the lines that carry a
--- comment stay visible.
--- @return boolean|nil visible nil when the buffer holds no threads
function M.toggle_text(bufnr)
  local state = rendered[bufnr]
  if not state then
    return nil
  end
  state.show_text = not state.show_text
  place(bufnr)
  return state.show_text
end

function M.clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  rendered[bufnr] = nil
end

function M.is_rendered(bufnr)
  return rendered[bufnr] ~= nil
end

--- Root comment of the thread on the cursor line.
function M.thread_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local state = rendered[bufnr]
  if not state then
    return nil, 'no thread is displayed: run :Bitbucket threads'
  end

  local row = vim.fn.line('.') - 1
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, { row, 0 }, { row, -1 }, {})
  for _, mark in ipairs(marks) do
    local thread = state.marks[mark[1]]
    if thread then
      return thread, nil
    end
  end
  return nil, 'no comment thread on this line'
end

--- Move the cursor to the next or the previous thread of the buffer.
--- @param direction number 1 forward, -1 backward
function M.jump(direction)
  local bufnr = vim.api.nvim_get_current_buf()
  if not rendered[bufnr] then
    return vim.notify('no thread is displayed', vim.log.levels.WARN)
  end

  local rows = {}
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})) do
    rows[#rows + 1] = mark[2]
  end
  table.sort(rows)
  if #rows == 0 then
    return vim.notify('no thread in this file', vim.log.levels.INFO)
  end

  local current = vim.fn.line('.') - 1
  local target
  if direction > 0 then
    for _, row in ipairs(rows) do
      if row > current then
        target = row
        break
      end
    end
    target = target or rows[1]
  else
    for i = #rows, 1, -1 do
      if rows[i] < current then
        target = rows[i]
        break
      end
    end
    target = target or rows[#rows]
  end

  vim.api.nvim_win_set_cursor(0, { target + 1, 0 })
end

--- Open a buffer in a float, a split or a vertical split, as configured.
--- @param bufnr number
--- @param opts table { style, title, width, height }
--- @return number win
local function open_window(bufnr, opts)
  local window = config.opts.window
  local style = opts.style or window.style
  local width = math.min(opts.width or window.width, vim.o.columns - 4)
  local height = math.min(opts.height or window.height, vim.o.lines - 4)

  if style == 'split' or style == 'vsplit' then
    vim.cmd(('belowright %d%s'):format(style == 'split' and height or width, style))
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, bufnr)
    vim.wo[win].winbar = opts.title or ''
    return win
  end

  return vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = 'minimal',
    border = window.border,
    title = ' ' .. (opts.title or '') .. ' ',
    title_pos = 'center',
  })
end

--- Make the window a markdown window. The filetype is set after the window
--- exists, so render-markdown and treesitter attach to a buffer that is shown.
local function as_markdown(bufnr, win)
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].conceallevel = 2
  vim.wo[win].spell = config.opts.window.spell
  vim.bo[bufnr].filetype = 'markdown'
end

--- Open a markdown buffer and pass its text to on_submit.
--- @param opts table { title, prefill, style }
--- @param on_submit fun(text: string)
function M.compose(opts, on_submit)
  opts = opts or {}

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = 'wipe'
  if opts.prefill and opts.prefill ~= '' then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(opts.prefill, '\n'))
  end

  local title = ('%s  (<C-s> send, q cancel)'):format(opts.title or 'Bitbucket comment')
  local win = open_window(bufnr, { title = title, style = opts.style })
  as_markdown(bufnr, win)
  vim.api.nvim_win_set_cursor(win, { math.max(1, vim.api.nvim_buf_line_count(bufnr)), 0 })
  vim.cmd.startinsert()

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function submit()
    local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n'))
    close()
    if text == '' then
      return vim.notify('empty comment discarded', vim.log.levels.INFO)
    end
    on_submit(text)
  end

  vim.keymap.set({ 'n', 'i' }, '<C-s>', submit, { buffer = bufnr, desc = 'Send comment' })
  vim.keymap.set('n', 'q', close, { buffer = bufnr, desc = 'Cancel comment' })
end

local function timestamp(millis)
  if not millis then
    return ''
  end
  return os.date('%Y-%m-%d %H:%M', math.floor(millis / 1000))
end

--- One thread as markdown. Replies nest as block quotes, so the depth stays
--- readable after rendering.
local function thread_markdown(thread)
  local anchor = thread.anchor or {}
  local where = anchor.path and ('%s:%s'):format(anchor.path, anchor.line or '-') or 'pull request'
  local kind = anchor.fileType and (' · %s %s'):format(anchor.fileType, anchor.lineType or '')
    or ''

  local lines = { ('# %s%s'):format(where, kind) }
  if thread.state == 'RESOLVED' then
    lines[#lines + 1] = ''
    lines[#lines + 1] = '`resolved`'
  end

  local function add(comment, depth)
    local quote = string.rep('> ', depth)
    local author = comment.author and comment.author.displayName or 'unknown'
    lines[#lines + 1] = ''
    lines[#lines + 1] = ('%s**%s** · %s'):format(quote, author, timestamp(comment.createdDate))
    lines[#lines + 1] = quote
    for line in vim.gsplit(comment.text or '', '\n', { plain = true }) do
      lines[#lines + 1] = quote .. line
    end
    for _, reply in ipairs(comment.comments or {}) do
      add(reply, depth + 1)
    end
  end

  add(thread, 0)
  return lines
end

--- Read one thread in a markdown window.
--- @param thread table root comment
--- @param handlers table|nil { reply, resolve } called after the window closes
--- @param opts table|nil { style }
function M.view(thread, handlers, opts)
  opts = opts or {}
  handlers = handlers or {}

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, thread_markdown(thread))
  vim.bo[bufnr].modifiable = false

  local win = open_window(bufnr, {
    title = 'Thread  (r reply, R resolve, q close)',
    style = opts.style,
  })
  as_markdown(bufnr, win)

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set('n', 'q', close, { buffer = bufnr, desc = 'Close thread' })
  for key, handler in pairs({ r = handlers.reply, R = handlers.resolve }) do
    if handler then
      vim.keymap.set('n', key, function()
        close()
        handler(thread)
      end, { buffer = bufnr, desc = key == 'r' and 'Reply to thread' or 'Resolve thread' })
    end
  end
end

return M
