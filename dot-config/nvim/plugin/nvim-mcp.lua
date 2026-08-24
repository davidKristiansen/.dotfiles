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
    require('nvim-mcp').setup({})
  end,
})
