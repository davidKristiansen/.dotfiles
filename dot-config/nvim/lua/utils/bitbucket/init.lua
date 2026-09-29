-- SPDX-License-Identifier: MIT
-- Pull request review against Bitbucket Data Center, over the REST API 1.0.
--
-- Comments come from, and go to, the pull request of the current branch. A
-- diffview window states its diff side, so a comment from there is anchored
-- exactly. A plain file buffer is accepted only while its line numbers still
-- match the pull request; the bang forces it.
local M = {}

local anchor = require('utils.bitbucket.anchor')
local config = require('utils.bitbucket.config')
local pr_module = require('utils.bitbucket.pr')
local ui = require('utils.bitbucket.ui')

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Bitbucket' })
end

local function fail(err)
  notify(err, vim.log.levels.ERROR)
end

-- Marks for every file of the pull request. One fetch feeds every buffer.
local auto = { state = 'idle', index = {} }

--- Repository-relative path of a file buffer, or nil for anything else.
local function buffer_path(bufnr)
  if vim.bo[bufnr].buftype ~= '' then
    return nil
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return nil
  end
  local location = config.location()
  if not location then
    return nil
  end
  return vim.fs.relpath(location.root, name)
end

--- Draw the marks of one buffer out of the fetched threads.
local function auto_render(bufnr)
  if auto.state ~= 'ready' or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  local path = buffer_path(bufnr)
  local threads = path and auto.index[path]
  if threads then
    ui.render(bufnr, 'TO', threads)
  end
end

--- Fetch every comment of the pull request once, then mark every open buffer.
--- Any failure turns the marks off rather than reporting on each file opened.
local function auto_load()
  if auto.state ~= 'idle' or not config.opts.auto_threads then
    return
  end
  auto.state = 'loading'

  pr_module.resolve(function(pr, err)
    if not pr then
      auto.state = 'off'
      return vim.notify('bitbucket marks off: ' .. err, vim.log.levels.DEBUG)
    end
    pr_module.all_comments(pr, function(threads, comments_err)
      if not threads then
        auto.state = 'off'
        return vim.notify('bitbucket marks off: ' .. comments_err, vim.log.levels.DEBUG)
      end

      auto.index = {}
      for _, thread in ipairs(threads) do
        local path = thread.anchor and thread.anchor.path
        if path then
          auto.index[path] = auto.index[path] or {}
          table.insert(auto.index[path], thread)
        end
      end
      auto.state = 'ready'

      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        auto_render(bufnr)
      end
    end)
  end, { interactive = false })
end

--- Read the comments again on the next file opened.
local function auto_invalidate()
  if auto.state ~= 'off' then
    auto.state = 'idle'
    auto.index = {}
  end
end

--- The thread an action applies to: the one passed in, or the one on the cursor
--- line. A window that shows a thread hands it over, because it closes first.
local function with_thread(opts, fn)
  if opts.thread then
    return fn(opts.thread)
  end
  local thread, err = ui.thread_at_cursor()
  if not thread then
    return fail(err)
  end
  fn(thread)
end

--- Report a checkout that no longer matches the pull request, so a reader knows
--- that the displayed line numbers can be off.
local function warn_on_drift(pr)
  local head = pr_module.head()
  if pr.from_hash and head and head ~= pr.from_hash then
    notify(
      ('HEAD %s is not the source commit %s of #%d: line numbers can differ'):format(
        head:sub(1, 8),
        pr.from_hash:sub(1, 8),
        pr.id
      ),
      vim.log.levels.WARN
    )
  end
end

--- Resolve the pull request, then hand it to fn.
local function with_pr(fn)
  pr_module.resolve(function(pr, err)
    if not pr then
      return fail(err)
    end
    fn(pr)
  end)
end

--- Draw the threads of the current file, and report how many there are.
local function refresh(pr, bufnr, target)
  auto_invalidate()
  pr_module.comments(pr, target.path, function(threads, err)
    if not threads then
      return fail(err)
    end
    local shown = ui.render(bufnr, target.side, threads)
    notify(('#%d: %d thread(s) in %s'):format(pr.id, shown, target.path))
  end)
end

--- A pull request that moved on since the diff was read. The server reports it
--- with HTTP 409, because the anchor names hashes that are no longer current.
local function is_out_of_date(err)
  return err:match('409') ~= nil
end

--- Build the anchor and post. One retry against a fresh diff, because the
--- pull request can take a push while the comment is being written.
local function submit_comment(pr, target, bufnr, text, retried)
  pr_module.build_anchor(pr, target, function(built, anchor_err)
    if not built then
      return fail(anchor_err)
    end

    pr_module.post_comment(pr, text, built, nil, function(_, post_err)
      if not post_err then
        notify(('comment posted on %s:%d'):format(target.path, built.line))
        if ui.is_rendered(bufnr) then
          refresh(pr, bufnr, target)
        end
        return
      end

      if retried or not is_out_of_date(post_err) then
        return fail(post_err)
      end

      notify('the pull request moved on: reading the diff again', vim.log.levels.WARN)
      pr_module.invalidate(pr)
      with_pr(function(fresh)
        submit_comment(fresh, target, bufnr, text, true)
      end)
    end)
  end)
end

--- Comment on the cursor line, or on a selection.
--- @param opts table|nil { force, style, line1, line2 }
function M.comment(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()

  with_pr(function(pr)
    local target, err = anchor.current(pr, { force = opts.force })
    if not target then
      return fail(err .. ' (add ! to post anyway)')
    end

    local first, last = opts.line1, opts.line2
    if first and last and last > first then
      target.line = first
    end

    pr_module.build_anchor(pr, target, function(built, anchor_err)
      if not built then
        return fail(anchor_err)
      end

      local title = ('#%d  %s:%d  %s %s'):format(
        pr.id,
        vim.fs.basename(target.path),
        built.line,
        built.fileType,
        built.lineType
      )
      ui.compose({ title = title, style = opts.style }, function(text)
        if first and last and last > first then
          text = text .. '\n\n' .. anchor.quote(bufnr, first, last)
        end
        submit_comment(pr, target, bufnr, text, false)
      end)
    end)
  end)
end

--- Comment on the pull request itself, with no anchor.
function M.discuss(opts)
  opts = opts or {}
  with_pr(function(pr)
    ui.compose({ title = ('#%d  %s'):format(pr.id, pr.title), style = opts.style }, function(text)
      pr_module.post_comment(pr, text, nil, nil, function(_, err)
        if err then
          return fail(err)
        end
        notify(('comment posted on #%d'):format(pr.id))
      end)
    end)
  end)
end

--- Reply to the thread on the cursor line.
function M.reply(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()

  with_thread(opts, function(thread)
    with_pr(function(pr)
      local author = thread.author and thread.author.displayName or 'unknown'
      local title = ('Reply to %s'):format(author)
      ui.compose({ title = title, style = opts.style }, function(text)
        pr_module.post_comment(pr, text, nil, thread.id, function(_, post_err)
          if post_err then
            return fail(post_err)
          end
          notify('reply posted')
          local target = { path = thread.anchor.path, side = thread.anchor.fileType }
          refresh(pr, bufnr, target)
        end)
      end)
    end)
  end)
end

--- Mark the thread on the cursor line resolved.
function M.resolve(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()

  with_thread(opts, function(thread)
    with_pr(function(pr)
      local target = { path = thread.anchor.path, side = thread.anchor.fileType }

      local function try(candidate, retried)
        pr_module.resolve_comment(pr, candidate, function(_, resolve_err)
          if not resolve_err then
            notify('thread resolved')
            return refresh(pr, bufnr, target)
          end
          if retried or not is_out_of_date(resolve_err) then
            return fail(resolve_err)
          end

          -- Someone replied while the thread was on screen, so the version the
          -- buffer holds is behind. Read the current one and resolve that.
          pr_module.comments(pr, target.path, function(threads, comments_err)
            if not threads then
              return fail(comments_err)
            end
            for _, current in ipairs(threads) do
              if current.id == candidate.id then
                return try(current, true)
              end
            end
            fail(resolve_err)
          end)
        end)
      end

      try(thread, false)
    end)
  end)
end

--- Report what the cursor position resolves to, and whether the server agrees,
--- without posting anything.
function M.check()
  with_pr(function(pr)
    local target, err = anchor.current(pr, { force = true })
    if not target then
      return fail(err)
    end

    pr_module.diff_index(pr, target.path, function(diff, diff_err)
      if not diff then
        return fail(diff_err)
      end

      local entry = diff.index[target.side][target.line]
      local here = vim.trim(target.text or '')
      local there = entry and vim.trim(entry.text or '') or nil
      local agrees = there ~= nil and there == here

      notify(
        table.concat({
          ('#%d  %s'):format(pr.id, pr.title),
          ('path    %s'):format(target.path),
          ('anchor  %s line %d, from a %s buffer'):format(target.side, target.line, target.surface),
          ('diff    %s -> %s'):format(
            (diff.from_hash or '?'):sub(1, 8),
            (diff.to_hash or '?'):sub(1, 8)
          ),
          ('HEAD    %s, source of the pull request %s'):format(
            (pr_module.head() or '?'):sub(1, 8),
            (pr.from_hash or '?'):sub(1, 8)
          ),
          ('here    %s'):format(here),
          ('server  %s'):format(
            entry and ('[%s] %s'):format(entry.type, there) or 'the line is not in the diff'
          ),
          ('match   %s'):format(agrees and 'yes' or 'NO'),
        }, '\n'),
        agrees and vim.log.levels.INFO or vim.log.levels.WARN
      )
    end)
  end)
end

--- Read the thread on the cursor line in a markdown window.
function M.view(opts)
  opts = opts or {}
  with_thread(opts, function(thread)
    ui.view(thread, {
      reply = function(handed)
        M.reply({ thread = handed, style = opts.style })
      end,
      resolve = function(handed)
        M.resolve({ thread = handed })
      end,
    }, { style = opts.style })
  end)
end

--- Ask before a change that the server cannot undo.
local function confirm(question)
  return vim.fn.confirm(question, '&Yes\n&No', 2) == 1
end

--- Delete the thread on the cursor line.
function M.delete(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()

  with_thread(opts, function(thread)
    if #(thread.comments or {}) > 0 then
      return fail('the thread has replies, so the server keeps it')
    end
    local first = vim.split(thread.text or '', '\n')[1] or ''
    if not confirm(('Delete this comment?\n%s'):format(first)) then
      return notify('kept')
    end

    with_pr(function(pr)
      pr_module.delete_comment(pr, thread, function(_, err)
        if err then
          return fail(err)
        end
        notify('comment deleted')
        local target = { path = thread.anchor.path, side = thread.anchor.fileType }
        refresh(pr, bufnr, target)
      end)
    end)
  end)
end

--- Put the thread on the cursor line at another line. The API cannot change an
--- anchor, so the text is posted at the new line first and the old comment is
--- deleted after that succeeds.
function M.move(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()

  with_thread(opts, function(thread)
    if #(thread.comments or {}) > 0 then
      return fail('the thread has replies, so it cannot move')
    end

    vim.ui.input({
      prompt = 'Move the comment to line: ',
      default = tostring(thread.anchor and thread.anchor.line or vim.fn.line('.')),
    }, function(answer)
      local line = tonumber(answer)
      if not line then
        return notify('move cancelled')
      end

      with_pr(function(pr)
        local target = {
          path = thread.anchor.path,
          src_path = thread.anchor.srcPath or thread.anchor.path,
          side = thread.anchor.fileType,
          line = line,
          text = vim.fn.getbufline(bufnr, line)[1],
          force = opts.force,
        }

        pr_module.build_anchor(pr, target, function(built, anchor_err)
          if not built then
            return fail(anchor_err)
          end
          pr_module.post_comment(pr, thread.text, built, nil, function(_, post_err)
            if post_err then
              return fail(post_err)
            end
            -- The text is safe on the server now, so the old one can go.
            pr_module.delete_comment(pr, thread, function(_, delete_err)
              if delete_err then
                return fail(
                  ('posted at line %d, but the comment at line %d stays: %s'):format(
                    line,
                    thread.anchor.line,
                    delete_err
                  )
                )
              end
              notify(('comment moved to line %d'):format(line))
              refresh(pr, bufnr, target)
            end)
          end)
        end)
      end)
    end)
  end)
end

--- Show or hide the threads of the current file.
function M.threads()
  local bufnr = vim.api.nvim_get_current_buf()
  if ui.is_rendered(bufnr) then
    local visible = ui.toggle_text(bufnr)
    return notify(visible and 'comment text shown' or 'comment text hidden, signs stay')
  end

  with_pr(function(pr)
    local target, err = anchor.current(pr, { force = true })
    if not target then
      return fail(err)
    end
    if target.surface == 'buffer' then
      warn_on_drift(pr)
    end
    refresh(pr, bufnr, target)
  end)
end

--- Pick a thread of the whole pull request and jump to it.
function M.list()
  with_pr(function(pr)
    pr_module.all_comments(pr, function(threads, err)
      if not threads then
        return fail(err)
      end
      if #threads == 0 then
        return notify(('#%d has no comment'):format(pr.id))
      end

      local labels, by_label = {}, {}
      for _, thread in ipairs(threads) do
        local place = 'pull request'
        if thread.anchor and thread.anchor.path then
          place = ('%s:%s'):format(thread.anchor.path, thread.anchor.line or '-')
        end
        local first = vim.split(thread.text or '', '\n')[1] or ''
        local label = ('%s  %s  %s'):format(
          place,
          thread.author and thread.author.displayName or 'unknown',
          first
        )
        labels[#labels + 1] = label
        by_label[label] = thread
      end

      require('utils.picker').pick(labels, {
        prompt = ('#%d threads> '):format(pr.id),
        on_choice = function(label)
          local thread = by_label[label]
          if not (thread and thread.anchor and thread.anchor.path) then
            return
          end
          local location = config.location()
          local root = location and location.root or vim.fn.getcwd()
          vim.cmd.edit(vim.fn.fnameescape(root .. '/' .. thread.anchor.path))
          if thread.anchor.line then
            pcall(vim.api.nvim_win_set_cursor, 0, { thread.anchor.line, 0 })
          end
          M.threads()
        end,
      })
    end)
  end)
end

--- Choose which pull request the commands act on.
function M.pick()
  pr_module.clear_active()
  pr_module.pick(nil, function(pr, err)
    if not pr then
      return fail(err)
    end
    notify(('#%d %s (%s -> %s)'):format(pr.id, pr.title, pr.from_ref, pr.to_ref))
  end)
end

--- Open the pull request in the browser.
function M.open()
  with_pr(function(pr)
    local location, err = config.location()
    if not location then
      return fail(err)
    end
    vim.ui.open(config.web_url(location, pr.id))
  end)
end

--- Report which pull request the commands act on.
function M.info()
  with_pr(function(pr)
    local location = config.location()
    notify(
      ('#%d %s\n%s -> %s\nsource %s\n%s\nauth %s'):format(
        pr.id,
        pr.title,
        pr.from_ref,
        pr.to_ref,
        (pr.from_hash or '?'):sub(1, 8),
        location and location.base or '?',
        config.auth_source or 'not resolved yet'
      )
    )
  end)
end

local subcommands = {
  comment = M.comment,
  discuss = M.discuss,
  reply = M.reply,
  resolve = M.resolve,
  threads = M.threads,
  view = M.view,
  check = M.check,
  delete = M.delete,
  move = M.move,
  hide = function()
    ui.clear(vim.api.nvim_get_current_buf())
    notify('marks removed from this buffer')
  end,
  list = M.list,
  pr = M.pick,
  open = M.open,
  info = M.info,
  logout = function()
    config.forget_token()
    notify('token forgotten')
  end,
  reload = function()
    config.forget()
    pr_module.clear_active()
    auto.state = 'idle'
    auto.index = {}
    M.refresh()
    notify('git configuration read again')
  end,
}

local names = vim.tbl_keys(subcommands)
table.sort(names)

local keys = {
  { 'n', '<leader>gcc', ':Bitbucket comment<CR>', 'Comment on line' },
  { 'v', '<leader>gcc', ':Bitbucket comment<CR>', 'Comment on selection' },
  { 'n', '<leader>gcd', ':Bitbucket discuss<CR>', 'Comment on the pull request' },
  { 'n', '<leader>gcr', ':Bitbucket reply<CR>', 'Reply to thread' },
  { 'n', '<leader>gcR', ':Bitbucket resolve<CR>', 'Resolve thread' },
  { 'n', '<leader>gct', ':Bitbucket threads<CR>', 'Toggle threads' },
  { 'n', '<leader>gcv', ':Bitbucket view<CR>', 'Read thread in a window' },
  { 'n', '<leader>gcm', ':Bitbucket move<CR>', 'Move thread to another line' },
  { 'n', '<leader>gcx', ':Bitbucket delete<CR>', 'Delete thread' },
  { 'n', '<leader>gcl', ':Bitbucket list<CR>', 'List threads' },
  { 'n', '<leader>gcp', ':Bitbucket pr<CR>', 'Select pull request' },
  { 'n', '<leader>gco', ':Bitbucket open<CR>', 'Open in browser' },
  { 'n', '<leader>gci', ':Bitbucket info<CR>', 'Pull request info' },
}

local active = false
local group_registered = false

--- Label the prefix for which-key on first activation, so a checkout that is not
--- on Bitbucket shows no empty group.
local function register_group()
  if group_registered then
    return
  end
  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add({ { '<leader>gc', group = 'review (bitbucket)' } }, { mode = { 'n', 'v' } })
    group_registered = true
  end
end

--- Install the command and the keymaps.
function M.activate()
  if active then
    return
  end
  active = true

  vim.api.nvim_create_user_command('Bitbucket', function(args)
    local fn = subcommands[args.fargs[1]]
    if not fn then
      return notify('Usage: :Bitbucket {' .. table.concat(names, '|') .. '}', vim.log.levels.WARN)
    end
    local style = args.fargs[2]
    if style and not vim.tbl_contains({ 'float', 'split', 'vsplit' }, style) then
      return notify(('unknown window style %q'):format(style), vim.log.levels.WARN)
    end
    fn({
      force = args.bang,
      style = style,
      line1 = args.range > 0 and args.line1 or nil,
      line2 = args.range > 0 and args.line2 or nil,
    })
  end, {
    nargs = '+',
    bang = true,
    range = true,
    complete = function(_, line)
      local parts = vim.split(line, '%s+')
      if #parts == 2 then
        return vim.tbl_filter(function(name)
          return vim.startswith(name, parts[2])
        end, names)
      end
      if #parts == 3 and vim.tbl_contains({ 'comment', 'discuss', 'reply', 'view' }, parts[2]) then
        return vim.tbl_filter(function(style)
          return vim.startswith(style, parts[3])
        end, { 'float', 'split', 'vsplit' })
      end
      return {}
    end,
    desc = 'Review a Bitbucket pull request',
  })

  for _, key in ipairs(keys) do
    vim.keymap.set(key[1], key[2], key[3], { silent = true, desc = key[4] })
  end

  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('BitbucketMarks', { clear = true }),
    desc = 'Mark the comments of the pull request in a file that has them',
    callback = function(event)
      auto_load()
      auto_render(event.buf)
    end,
  })

  vim.keymap.set('n', ']r', function()
    ui.jump(1)
  end, { desc = 'Next review thread' })
  vim.keymap.set('n', '[r', function()
    ui.jump(-1)
  end, { desc = 'Prev review thread' })

  register_group()
end

--- Remove the command and the keymaps, so they never shadow anything in a
--- checkout that is not on Bitbucket.
function M.deactivate()
  if not active then
    return
  end
  active = false

  pcall(vim.api.nvim_del_augroup_by_name, 'BitbucketMarks')
  pcall(vim.api.nvim_del_user_command, 'Bitbucket')
  for _, key in ipairs(keys) do
    pcall(vim.keymap.del, key[1], key[2])
  end
  pcall(vim.keymap.del, 'n', ']r')
  pcall(vim.keymap.del, 'n', '[r')
end

--- Match the command and the keymaps to the checkout of the current directory.
function M.refresh()
  if config.is_bitbucket() then
    M.activate()
  else
    M.deactivate()
  end
end

function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_autocmd({ 'DirChanged', 'VimEnter' }, {
    group = vim.api.nvim_create_augroup('BitbucketActivate', { clear = true }),
    desc = 'Enable the Bitbucket commands only inside a Bitbucket checkout',
    callback = function()
      M.refresh()
    end,
  })

  M.refresh()
end

return M
