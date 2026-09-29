-- SPDX-License-Identifier: MIT
-- Endpoint, repository and credential resolution for Bitbucket Data Center.
--
-- No host name lives in this file. Everything comes out of git: the `bitbucket.*`
-- config keys, the remote URLs, and the `insteadOf` rewrites. $BITBUCKET_URL and
-- `opts.url` stay as a manual override for a checkout that git cannot describe.
local M = {}

local defaults = {
  -- Manual overrides. All three are derived from git when they stay nil.
  url = nil,
  project = nil,
  repo = nil,
  url_env = 'BITBUCKET_URL',
  remote = 'origin',
  -- Lua patterns matched against a remote URL. A match marks the checkout as
  -- Bitbucket even when the URL carries no /scm/ path, which an ssh-only remote
  -- does not. `git config bitbucket.url <base>` does the same, per checkout.
  hosts = {},
  -- Credentials. An HTTP access token, not an app password: Profile ->
  -- Manage account -> HTTP access tokens. A function is called on first use.
  token = nil,
  token_env = 'BITBUCKET_TOKEN',
  token_file = nil,
  -- Ask git for the credentials of the endpoint. This reaches every configured
  -- credential helper, so a token that git push already uses needs no second
  -- copy. git sends its credentials as basic auth, so this module does too.
  use_git_credential = true,
  -- Auth scheme for a token that does not come from git: 'auto' sends a bearer
  -- token, or basic auth when `username` is set. 'bearer' and 'basic' force one.
  auth_scheme = 'auto',
  username = nil,
  -- Extra curl arguments, for a corporate CA bundle or a proxy.
  curl_args = {},
  -- Whole-file context, so every line of a changed file is anchorable.
  context_lines = -1,
  -- Rendering.
  signs = { thread = '󰆉', resolved = '󰄬' },
  max_lines = 6,
  -- Mark the comments of the pull request in every file that has them, as it
  -- opens. One request per pull request feeds every buffer.
  auto_threads = true,
  -- The composer and the thread reader. Both are markdown buffers, so
  -- render-markdown and treesitter attach to them.
  window = {
    style = 'float',
    width = 84,
    height = 16,
    border = 'rounded',
    spell = true,
  },
}

M.opts = vim.deepcopy(defaults)

local auth_cache = nil
local git_cache = {}
local location_cache = {}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})
  M.forget()
  M.forget_token()
end

--- Drop every cached lookup, so the next call reads git again.
function M.forget()
  git_cache = {}
  location_cache = {}
end

function M.root()
  local cwd = vim.fn.getcwd()
  return vim.fs.root(cwd, '.git') or cwd
end

--- The git configuration that names a Bitbucket endpoint: the remotes, the URL
--- rewrites, and the `bitbucket.*` keys. One subprocess per checkout.
--- @return table<string, string[]> values keyed by the lowercase config key
local function git_config(root)
  if git_cache[root] then
    return git_cache[root]
  end

  local res = vim
    .system({
      'git',
      '-C',
      root,
      'config',
      '--get-regexp',
      [[^(remote\..*\.(push)?url|url\..*\.(push)?insteadof|bitbucket\..*)$]],
    }, { text = true })
    :wait()

  local config = {}
  if res.code == 0 then
    for line in vim.gsplit(res.stdout or '', '\n', { plain = true }) do
      local key, value = line:match('^(%S+)%s+(.*)$')
      if key then
        config[key] = config[key] or {}
        table.insert(config[key], vim.trim(value))
      end
    end
  end

  git_cache[root] = config
  return config
end

--- Remote URLs, the configured remote first, so it wins every derivation.
local function remote_urls(config)
  local preferred, rest = {}, {}
  for key, values in pairs(config) do
    local name = key:match('^remote%.(.-)%.pushurl$') or key:match('^remote%.(.-)%.url$')
    if name then
      local into = name == M.opts.remote and preferred or rest
      vim.list_extend(into, values)
    end
  end
  vim.list_extend(preferred, rest)
  return preferred
end

--- Endpoint base of an http Bitbucket URL, up to the /scm/ prefix.
local function base_of(url)
  return url:match('^(https?://.-)/scm/')
end

--- Project key and repository slug of any Bitbucket remote form.
local function project_repo(url)
  local project, repo = url:match('/scm/([^/]+)/(.+)$')
  if not project then
    project, repo = url:match('^ssh://[^/]+/([^/]+)/(.+)$')
  end
  if not project then
    project, repo = url:match('^[^/]+:([^/]+)/(.+)$')
  end
  if repo then
    repo = repo:gsub('%.git$', '')
  end
  return project, repo
end

--- Recover an http endpoint from an ssh remote through the URL rewrites of git.
--- A rewrite reads `url.<replacement>.insteadOf = <original>`, so an ssh remote
--- that starts with a replacement names its http original.
local function base_from_rewrites(config, urls)
  for key, values in pairs(config) do
    local replacement = key:match('^url%.(.+)%.insteadof$')
      or key:match('^url%.(.+)%.pushinsteadof$')
    if replacement then
      for _, url in ipairs(urls) do
        if vim.startswith(url, replacement) then
          for _, original in ipairs(values) do
            local base = base_of(original)
            if base then
              return base
            end
          end
        end
      end
    end
  end
end

local function first(values)
  return values and values[1] or nil
end

--- Whether this checkout talks to Bitbucket at all. Cheap enough to run on every
--- directory change: it reads one cached git configuration. A resolvable endpoint
--- is the signal; a `hosts` pattern asserts one that git cannot describe yet.
function M.is_bitbucket()
  if M.opts.url then
    return true
  end

  for _, url in ipairs(remote_urls(git_config(M.root()))) do
    for _, pattern in ipairs(M.opts.hosts) do
      if url:match(pattern) then
        return true
      end
    end
  end

  return M.location() ~= nil
end

--- Resolve where to send requests for the current checkout.
--- @return table|nil location { base, project, repo, root }
--- @return string|nil error
function M.location()
  local root = M.root()
  if location_cache[root] then
    return location_cache[root]
  end

  local config = git_config(root)
  local urls = remote_urls(config)
  if #urls == 0 then
    return nil, ('no git remote in %s'):format(root)
  end

  local base = M.opts.url or first(config['bitbucket.url'])
  local project = M.opts.project or first(config['bitbucket.project'])
  local repo = M.opts.repo or first(config['bitbucket.repo'])

  for _, url in ipairs(urls) do
    base = base or base_of(url)
    if not (project and repo) then
      local p, r = project_repo(url)
      project, repo = project or p, repo or r
    end
  end

  base = base or base_from_rewrites(config, urls) or vim.env[M.opts.url_env]

  if not base then
    return nil,
      ('no http endpoint for %s: run `git config bitbucket.url <https://host/context>`'):format(
        urls[1]
      )
  end
  if not (project and repo) then
    return nil,
      ('cannot derive the project and the repository from %s: run `git config bitbucket.project <KEY>` and `git config bitbucket.repo <slug>`'):format(
        urls[1]
      )
  end

  local location = {
    base = (base:gsub('/+$', '')),
    project = project,
    repo = repo,
    root = root,
  }
  location_cache[root] = location
  return location
end

--- Credentials of the endpoint, as git itself would resolve them. This reaches
--- the credential helpers, so ~/.git-credentials, the cache daemon and libsecret
--- all work without a second copy of the token.
--- @return table|nil credential { username, password }
local function git_credential()
  local location = M.location()
  if not location then
    return nil
  end

  local url = location.base .. '/scm/' .. location.project .. '/' .. location.repo .. '.git'
  local res = vim
    .system({ 'git', '-C', location.root, 'credential', 'fill' }, {
      text = true,
      stdin = ('url=%s\n\n'):format(url),
      -- Never let git open a prompt of its own: this module owns the prompt.
      env = { GIT_TERMINAL_PROMPT = '0', GCM_INTERACTIVE = 'never', GIT_ASKPASS = '' },
    })
    :wait()
  if res.code ~= 0 then
    return nil
  end

  local credential = {}
  for line in vim.gsplit(res.stdout or '', '\n', { plain = true }) do
    local key, value = line:match('^(%w+)=(.*)$')
    if key then
      credential[key] = value
    end
  end
  if credential.password and credential.password ~= '' then
    return credential
  end
end

local function basic(username, password)
  return 'Basic ' .. vim.base64.encode(('%s:%s'):format(username or '', password))
end

--- Header for a token, which carries no user name of its own.
local function token_header(token)
  local scheme = M.opts.auth_scheme
  if scheme == 'basic' or (scheme == 'auto' and M.opts.username) then
    return basic(M.opts.username, token)
  end
  return 'Bearer ' .. token
end

--- Value of the Authorization header, and where it came from.
--- @return string|nil header
--- @return string|nil error
function M.auth()
  if auth_cache then
    return auth_cache
  end

  local token = M.opts.token
  if type(token) == 'function' then
    token = token()
  end
  local source = token and 'opts.token' or nil

  if not token then
    token = vim.env[M.opts.token_env]
    source = token and ('$' .. M.opts.token_env) or nil
  end

  if not token and M.opts.token_file then
    local path = vim.fn.expand(M.opts.token_file)
    if vim.fn.filereadable(path) == 1 then
      token = vim.trim(vim.fn.readfile(path)[1] or '')
      source = 'token_file'
    end
  end

  if token and token ~= '' then
    auth_cache, M.auth_source = token_header(token), source
    return auth_cache
  end

  if M.opts.use_git_credential then
    local credential = git_credential()
    if credential then
      auth_cache = basic(credential.username, credential.password)
      M.auth_source = ('git credential (%s)'):format(credential.username or 'no user name')
      return auth_cache
    end
  end

  token = vim.trim(vim.fn.inputsecret('Bitbucket HTTP access token: '))
  if token == '' then
    return nil,
      ('no credentials: set $%s, opts.token_file, or store them with `git credential approve`'):format(
        M.opts.token_env
      )
  end
  auth_cache, M.auth_source = token_header(token), 'prompt'
  return auth_cache
end

--- Forget the cached credentials, so the next request resolves them again.
function M.forget_token()
  auth_cache = nil
  M.auth_source = nil
end

--- Browser URL of a pull request.
function M.web_url(location, pr_id)
  return ('%s/projects/%s/repos/%s/pull-requests/%d/overview'):format(
    location.base,
    location.project,
    location.repo,
    pr_id
  )
end

return M
