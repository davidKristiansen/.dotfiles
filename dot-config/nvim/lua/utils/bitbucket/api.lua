-- SPDX-License-Identifier: MIT
-- Asynchronous client for the Bitbucket Data Center REST API 1.0.
-- Every call runs curl through vim.system and returns on the main loop.
local M = {}

local config = require('utils.bitbucket.config')

local function encode_query(query)
  if not query or vim.tbl_isempty(query) then
    return ''
  end
  local parts = {}
  for key, value in pairs(query) do
    if type(value) == 'table' then
      for _, item in ipairs(value) do
        parts[#parts + 1] = ('%s=%s'):format(key, vim.uri_encode(tostring(item), 'rfc3986'))
      end
    else
      parts[#parts + 1] = ('%s=%s'):format(key, vim.uri_encode(tostring(value), 'rfc3986'))
    end
  end
  return '?' .. table.concat(parts, '&')
end

--- Percent-encode each path segment and keep the separators.
local function encode_path(path)
  local segments = {}
  for segment in vim.gsplit(path, '/', { plain = true }) do
    segments[#segments + 1] = vim.uri_encode(segment, 'rfc3986')
  end
  return table.concat(segments, '/')
end

--- Read the message out of a Bitbucket error payload.
local function error_message(status, decoded, raw)
  if type(decoded) == 'table' and type(decoded.errors) == 'table' and decoded.errors[1] then
    local first = decoded.errors[1]
    return first.message or first.exceptionName or raw
  end
  if status == 401 then
    return 'unauthorized: the HTTP access token is rejected or expired'
  end
  if status == 403 then
    return 'forbidden: the token lacks the repository write permission'
  end
  if status == 404 then
    return 'not found: check the project key, the repository slug and the pull request id'
  end
  return vim.trim(raw or ''):sub(1, 200)
end

--- @param method string
--- @param path string API path below /rest/api/1.0
--- @param opts table { query, body }
--- @param cb fun(result: table|nil, err: string|nil)
function M.request(method, path, opts, cb)
  opts = opts or {}

  local location, err = config.location()
  if not location then
    return cb(nil, err)
  end
  local auth, auth_err = config.auth()
  if not auth then
    return cb(nil, auth_err)
  end

  local url = location.base .. '/rest/api/1.0' .. path .. encode_query(opts.query)
  local args = {
    'curl',
    '-sS',
    '-w',
    '\n%{http_code}',
    '-X',
    method,
    '-H',
    'Authorization: ' .. auth,
    '-H',
    'Accept: application/json',
  }

  local body
  if opts.body then
    body = vim.json.encode(opts.body)
    vim.list_extend(args, { '-H', 'Content-Type: application/json', '--data-binary', '@-' })
  end
  vim.list_extend(args, config.opts.curl_args)
  args[#args + 1] = url

  vim.system(args, { text = true, stdin = body }, function(res)
    vim.schedule(function()
      if res.code ~= 0 and (res.stdout or '') == '' then
        return cb(nil, ('curl failed (exit %d): %s'):format(res.code, vim.trim(res.stderr or '')))
      end

      local payload, status = (res.stdout or ''):match('^(.-)\n(%d+)%s*$')
      if not status then
        return cb(nil, 'malformed curl response: ' .. vim.trim(res.stdout or ''):sub(1, 200))
      end
      status = tonumber(status)

      local decoded
      if vim.trim(payload) ~= '' then
        local ok, value = pcall(vim.json.decode, payload, { luanil = { object = true } })
        decoded = ok and value or nil
      end

      if status >= 400 then
        return cb(nil, ('HTTP %d: %s'):format(status, error_message(status, decoded, payload)))
      end
      cb(decoded or {}, nil)
    end)
  end)
end

function M.get(path, query, cb)
  M.request('GET', path, { query = query }, cb)
end

function M.post(path, body, cb)
  M.request('POST', path, { body = body }, cb)
end

function M.put(path, body, cb)
  M.request('PUT', path, { body = body }, cb)
end

function M.delete(path, query, cb)
  M.request('DELETE', path, { query = query }, cb)
end

--- Follow the page links of a paged endpoint and collect every value.
function M.paged(path, query, cb)
  local collected = {}

  local function fetch(start)
    local page_query = vim.tbl_extend('force', query or {}, { limit = 100, start = start })
    M.get(path, page_query, function(page, err)
      if err then
        return cb(nil, err)
      end
      vim.list_extend(collected, page.values or {})
      if page.isLastPage == false and page.nextPageStart then
        return fetch(page.nextPageStart)
      end
      cb(collected, nil)
    end)
  end

  fetch(0)
end

--- Path prefix for every repository-scoped endpoint.
function M.repo_path()
  local location, err = config.location()
  if not location then
    return nil, err
  end
  return ('/projects/%s/repos/%s'):format(encode_path(location.project), encode_path(location.repo))
end

M.encode_path = encode_path

return M
