-- SPDX-License-Identifier: MIT
-- nvim-mcp: MCP server for AI assistant integration (loaded on next tick).

-- Buffers that git opens for one edit. Each setup() call registers a socket,
-- so these short-lived instances must not add themselves to the target list.
local TRANSIENT = { 'COMMIT_EDITMSG$', 'MERGE_MSG$', 'git%-rebase%-todo$', 'TAG_EDITMSG$' }

local function is_transient()
  for _, arg in ipairs(vim.fn.argv()) do
    for _, pattern in ipairs(TRANSIENT) do
      if arg:match(pattern) then
        return true
      end
    end
  end
  return false
end

-- The `nvim-mcp` binary talks to the plugin over that socket, and the two must
-- come from the same revision. Build it from the checkout vim.pack manages.
local function build_server(path)
  vim.notify('nvim-mcp: building the server binary', vim.log.levels.INFO)
  vim.system(
    { 'cargo', 'install', '--path', path, '--root', vim.fn.expand('~/.local'), '--locked' },
    { text = true },
    vim.schedule_wrap(function(out)
      if out.code == 0 then
        vim.notify('nvim-mcp: server binary installed', vim.log.levels.INFO)
      else
        vim.notify('nvim-mcp: build failed\n' .. (out.stderr or ''), vim.log.levels.ERROR)
      end
    end)
  )
end

-- A Unix socket path stops at 108 bytes. The socket name carries the project
-- root, and the server globs for that exact name, so the name cannot be made
-- shorter. The plugin measures nothing and picks XDG_RUNTIME_DIR, so a deep
-- project fails with "Failed to start server: invalid argument". The server
-- searches /tmp as well, which is shorter, so try it second.
local SUN_PATH_MAX = 107

local function project_root()
  local out = vim.fn.systemlist({ 'git', 'rev-parse', '--show-toplevel' })
  if vim.v.shell_error == 0 and out[1] and out[1] ~= '' then
    return vim.trim(out[1])
  end
  return vim.fn.getcwd()
end

local function socket_path()
  local name = ('nvim-mcp.%s.%d.sock'):format((project_root():gsub('/', '%%')), vim.fn.getpid())
  -- XDG_RUNTIME_DIR comes first: it is mode 700, where /tmp is world readable.
  local dirs = {}
  if vim.env.XDG_RUNTIME_DIR and vim.env.XDG_RUNTIME_DIR ~= '' then
    dirs[#dirs + 1] = vim.env.XDG_RUNTIME_DIR
  end
  dirs[#dirs + 1] = '/tmp'
  for _, dir in ipairs(dirs) do
    local path = dir .. '/' .. name
    if #path <= SUN_PATH_MAX then
      return path
    end
  end
  return nil
end

require('utils.lazy').add({
  src = 'https://github.com/linw1995/nvim-mcp',
  cond = function()
    return not is_transient()
  end,
  on_pack_changed = function(ev)
    if ev.data.spec.name == 'nvim-mcp' and ev.data.kind == 'update' then
      build_server(ev.data.path)
    end
  end,
  config = function()
    local pipe = socket_path()
    if not pipe then
      vim.notify('nvim-mcp: the project path is too long for a socket name', vim.log.levels.WARN)
      return
    end
    require('nvim-mcp').setup({ pipe = pipe })
  end,
})
