-- SPDX-License-Identifier: MIT
-- Pull request resolution, diff classification and comment transport.
local M = {}

local api = require('utils.bitbucket.api')
local config = require('utils.bitbucket.config')

-- The pull request that commands act on, per checkout root.
local active = {}
-- Diff line classification, keyed by pull request id and file path.
local diff_cache = {}

local function root()
  return config.root()
end

local function git(...)
  local cmd = { 'git', '-C', root() }
  vim.list_extend(cmd, { ... })
  local res = vim.system(cmd, { text = true }):wait()
  if res.code ~= 0 then
    return nil
  end
  return vim.trim(res.stdout)
end

function M.branch()
  return git('rev-parse', '--abbrev-ref', 'HEAD')
end

function M.head()
  return git('rev-parse', 'HEAD')
end

--- Reduce an API pull request to the fields the module uses.
---
--- `fromRef` is the source branch and `toRef` is the target branch. A diff names
--- its sides the other way round: the old side is `fromHash` and the new side is
--- `toHash`. A comment anchor takes the diff sides, so it never takes these two
--- fields; it takes the hashes that the diff endpoint reports.
local function normalize(raw)
  return {
    id = raw.id,
    title = raw.title,
    from_ref = raw.fromRef and raw.fromRef.displayId,
    to_ref = raw.toRef and raw.toRef.displayId,
    from_hash = raw.fromRef and raw.fromRef.latestCommit,
    to_hash = raw.toRef and raw.toRef.latestCommit,
  }
end

function M.get_active()
  return active[root()]
end

function M.set_active(pr)
  active[root()] = pr
  return pr
end

function M.clear_active()
  active[root()] = nil
  diff_cache = {}
end

--- Fetch the open pull requests. Without a branch it fetches every open one.
--- @param branch string|nil
--- @param cb fun(prs: table[]|nil, err: string|nil)
function M.list(branch, cb)
  local repo, err = api.repo_path()
  if not repo then
    return cb(nil, err)
  end

  local query = { state = 'OPEN' }
  if branch then
    query.direction = 'OUTGOING'
    query.at = 'refs/heads/' .. branch
  end

  api.paged(repo .. '/pull-requests', query, function(values, list_err)
    if list_err then
      return cb(nil, list_err)
    end
    return cb(vim.tbl_map(normalize, values), nil)
  end)
end

--- Resolve the pull request to act on: the cached one, the single open pull
--- request of the current branch, or one the user picks.
--- @param cb fun(pr: table|nil, err: string|nil)
--- @param opts table|nil { interactive } set interactive=false to fail instead
---   of opening a picker, for a path that no keypress started
function M.resolve(cb, opts)
  opts = opts or {}
  local cached = M.get_active()
  if cached then
    return cb(cached, nil)
  end

  local branch = M.branch()
  if not branch then
    return cb(nil, 'not a git checkout')
  end

  M.list(branch, function(prs, err)
    if err then
      return cb(nil, err)
    end
    if #prs == 1 then
      return cb(M.set_active(prs[1]), nil)
    end
    if #prs == 0 then
      return cb(nil, ('no open pull request for %s: pick one with :Bitbucket pr'):format(branch))
    end
    if opts.interactive == false then
      return cb(
        nil,
        ('%d open pull requests for %s: pick one with :Bitbucket pr'):format(#prs, branch)
      )
    end
    M.pick(prs, cb)
  end)
end

--- Let the user choose the active pull request.
--- @param prs table[]|nil pull requests to choose from, or nil to fetch every open one
--- @param cb fun(pr: table|nil, err: string|nil)
function M.pick(prs, cb)
  local function choose(list)
    local labels, by_label = {}, {}
    for _, pr in ipairs(list) do
      local label = ('#%d  %s  (%s -> %s)'):format(pr.id, pr.title, pr.from_ref, pr.to_ref)
      labels[#labels + 1] = label
      by_label[label] = pr
    end
    require('utils.picker').pick(labels, {
      prompt = 'Bitbucket PR> ',
      on_choice = function(label)
        local pr = by_label[label]
        if pr then
          cb(M.set_active(pr), nil)
        end
      end,
    })
  end

  if prs then
    return choose(prs)
  end
  M.list(nil, function(list, err)
    if err then
      return cb(nil, err)
    end
    if #list == 0 then
      return cb(nil, 'no open pull request in this repository')
    end
    choose(list)
  end)
end

--- Map every line of one file to its diff line type and its text, per side.
--- The text is what proves that a line number means the same thing here and on
--- the server: the same number can point at a different line when the local
--- file is a different version of it.
local function build_index(diff)
  local index = { TO = {}, FROM = {} }
  for _, file in ipairs(diff.diffs or {}) do
    for _, hunk in ipairs(file.hunks or {}) do
      for _, segment in ipairs(hunk.segments or {}) do
        for _, line in ipairs(segment.lines or {}) do
          if segment.type == 'ADDED' then
            index.TO[line.destination] = { type = 'ADDED', text = line.line }
          elseif segment.type == 'REMOVED' then
            index.FROM[line.source] = { type = 'REMOVED', text = line.line }
          else
            index.TO[line.destination] = { type = 'CONTEXT', text = line.line }
            index.FROM[line.source] = { type = 'CONTEXT', text = line.line }
          end
        end
      end
    end
  end
  return index
end

--- Diff of one file in the pull request: the line types per side, and the two
--- hashes that the server anchors this diff to.
--- @param pr table
--- @param path string repository-relative path
--- @param cb fun(diff: table|nil, err: string|nil) { index, from_hash, to_hash }
function M.diff_index(pr, path, cb)
  local key = ('%d:%s'):format(pr.id, path)
  if diff_cache[key] then
    return cb(diff_cache[key], nil)
  end

  local repo, err = api.repo_path()
  if not repo then
    return cb(nil, err)
  end

  local endpoint = ('%s/pull-requests/%d/diff/%s'):format(repo, pr.id, api.encode_path(path))
  api.get(endpoint, {
    contextLines = config.opts.context_lines,
    withComments = false,
    diffType = 'EFFECTIVE',
  }, function(diff, diff_err)
    if diff_err then
      return cb(nil, diff_err)
    end
    local entry = {
      index = build_index(diff),
      from_hash = diff.fromHash,
      to_hash = diff.toHash,
    }
    diff_cache[key] = entry
    cb(entry, nil)
  end)
end

--- Drop what the server may have moved on from, so the next call fetches it
--- again. A push to either branch makes the cached diff and its hashes stale.
function M.invalidate(pr)
  if pr then
    local prefix = ('%d:'):format(pr.id)
    for key in pairs(diff_cache) do
      if vim.startswith(key, prefix) then
        diff_cache[key] = nil
      end
    end
  else
    diff_cache = {}
  end
  active[root()] = nil
end

--- Turn a buffer position into a Bitbucket comment anchor.
--- @param pr table
--- @param target table { path, line, side, src_path, text, force }
--- @param cb fun(anchor: table|nil, err: string|nil)
function M.build_anchor(pr, target, cb)
  M.diff_index(pr, target.path, function(diff, err)
    if err then
      return cb(nil, err)
    end

    local entry = diff.index[target.side][target.line]
    if not entry then
      return cb(
        nil,
        ('line %d of %s is not part of the pull request diff'):format(target.line, target.path)
      )
    end

    -- The server places the comment by number, so a number that names another
    -- line there than it does here puts the comment somewhere else.
    if target.text and entry.text and not target.force then
      if vim.trim(target.text) ~= vim.trim(entry.text) then
        return cb(
          nil,
          ('line %d of %s is a different line on the server\n  here:   %s\n  server: %s\nthe checkout is not the source of #%d (%s): check that commit out, or add ! to post at line %d as it stands there'):format(
            target.line,
            target.path,
            vim.trim(target.text),
            vim.trim(entry.text),
            pr.id,
            (pr.from_hash or '?'):sub(1, 8),
            target.line
          )
        )
      end
    end

    local line_type = entry.type

    local anchor = {
      path = target.path,
      line = target.line,
      lineType = line_type,
      fileType = target.side,
      diffType = 'EFFECTIVE',
      -- The hashes of this diff, as the server reports them. The server rejects
      -- an anchor that names any other pair with HTTP 409.
      fromHash = diff.from_hash,
      toHash = diff.to_hash,
    }
    if target.src_path and target.src_path ~= target.path then
      anchor.srcPath = target.src_path
    end
    cb(anchor, nil)
  end)
end

--- Post a comment. Without an anchor it becomes a pull request level comment.
--- @param pr table
--- @param text string
--- @param anchor table|nil
--- @param parent_id number|nil reply target
--- @param cb fun(comment: table|nil, err: string|nil)
function M.post_comment(pr, text, anchor, parent_id, cb)
  local repo, err = api.repo_path()
  if not repo then
    return cb(nil, err)
  end

  local body = { text = text }
  if anchor then
    body.anchor = anchor
  end
  if parent_id then
    body.parent = { id = parent_id }
  end

  api.post(('%s/pull-requests/%d/comments'):format(repo, pr.id), body, cb)
end

--- Flatten the activity stream into the comment shape of the comments endpoint.
local function comments_from_activities(values, path)
  local threads = {}
  for _, activity in ipairs(values) do
    if activity.action == 'COMMENTED' and activity.comment then
      local comment = activity.comment
      comment.anchor = comment.anchor or activity.commentAnchor
      if comment.anchor and comment.anchor.path == path then
        threads[#threads + 1] = comment
      end
    end
  end
  return threads
end

--- Comment threads anchored to one file.
--- @param pr table
--- @param path string
--- @param cb fun(threads: table[]|nil, err: string|nil)
function M.comments(pr, path, cb)
  local repo, err = api.repo_path()
  if not repo then
    return cb(nil, err)
  end

  local endpoint = ('%s/pull-requests/%d/comments'):format(repo, pr.id)
  api.paged(endpoint, {
    path = path,
    diffType = 'EFFECTIVE',
    anchorState = 'ALL',
  }, function(values, comments_err)
    if not comments_err then
      return cb(values, nil)
    end
    -- Instances that do not serve the comments endpoint still serve the
    -- activity stream, which carries the same comments.
    api.paged(
      ('%s/pull-requests/%d/activities'):format(repo, pr.id),
      {},
      function(activities, activities_err)
        if activities_err then
          return cb(nil, comments_err)
        end
        cb(comments_from_activities(activities, path), nil)
      end
    )
  end)
end

--- Delete a comment. The server refuses one that has replies, and the anchor of
--- a comment cannot be changed, so a comment moves by delete and post.
--- @param pr table
--- @param comment table root comment with id and version
--- @param cb fun(result: table|nil, err: string|nil)
function M.delete_comment(pr, comment, cb)
  local repo, err = api.repo_path()
  if not repo then
    return cb(nil, err)
  end
  api.delete(
    ('%s/pull-requests/%d/comments/%d'):format(repo, pr.id, comment.id),
    { version = comment.version },
    cb
  )
end

--- Mark a comment thread resolved.
--- @param pr table
--- @param comment table root comment with id and version
--- @param cb fun(comment: table|nil, err: string|nil)
function M.resolve_comment(pr, comment, cb)
  local repo, err = api.repo_path()
  if not repo then
    return cb(nil, err)
  end
  api.put(
    ('%s/pull-requests/%d/comments/%d'):format(repo, pr.id, comment.id),
    { version = comment.version, state = 'RESOLVED' },
    cb
  )
end

--- Every anchored comment of the pull request, across all files.
--- The activity stream is the only endpoint that serves them without a path.
--- @param pr table
--- @param cb fun(threads: table[]|nil, err: string|nil)
function M.all_comments(pr, cb)
  local repo, err = api.repo_path()
  if not repo then
    return cb(nil, err)
  end

  api.paged(
    ('%s/pull-requests/%d/activities'):format(repo, pr.id),
    {},
    function(values, activities_err)
      if activities_err then
        return cb(nil, activities_err)
      end

      local threads, seen = {}, {}
      for _, activity in ipairs(values) do
        if activity.action == 'COMMENTED' and activity.comment then
          local comment = activity.comment
          comment.anchor = comment.anchor or activity.commentAnchor
          if not seen[comment.id] then
            seen[comment.id] = true
            threads[#threads + 1] = comment
          end
        end
      end
      cb(threads, nil)
    end
  )
end

return M
