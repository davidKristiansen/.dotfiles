-- SPDX-License-Identifier: MIT
-- lua/plugins/mini/minis/sessions.lua
-- Configuration for mini.sessions
--
-- Sessions are named by full cwd path with '/' replaced by '%'
-- (e.g. "%Project%MacPyver"). Display names are stored in a single
-- JSON metadata file at ~/.local/share/nvim/session_meta.json.

local session_dir = vim.fn.stdpath('data') .. '/sessions'

--- Convert a full path to a session name (replace / with %).
local function path_to_session_name(path)
  return path:gsub('/', '%%')
end

--- Convert a session name back to a path.
local function session_name_to_path(name)
  return name:gsub('%%', '/')
end

--- Path to the single metadata JSON file (outside the sessions directory
--- so mini.sessions doesn't detect it as a session).
local meta_file = vim.fn.stdpath('data') .. '/session_meta.json'

--- Read the full metadata table from disk.
local function read_meta()
  local f = io.open(meta_file, 'r')
  if not f then
    return {}
  end
  local content = f:read('*a')
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  return ok and data or {}
end

--- Write the full metadata table to disk.
local function write_meta(data)
  local f = io.open(meta_file, 'w')
  if not f then
    return
  end
  f:write(vim.json.encode(data))
  f:close()
end

--- Read the display name for a session.
--- Falls back to the cwd basename.
local function get_display_name(session_name)
  local meta = read_meta()
  if meta[session_name] then
    return meta[session_name]
  end
  return vim.fn.fnamemodify(session_name_to_path(session_name), ':t')
end

--- Write a display name for a session.
local function set_display_name(session_name, display_name)
  local meta = read_meta()
  meta[session_name] = display_name
  write_meta(meta)
end

--- Check if a display name is already stored.
local function has_display_name(session_name)
  local meta = read_meta()
  return meta[session_name] ~= nil
end

--- Remove the display name for a session.
local function remove_display_name(session_name)
  local meta = read_meta()
  meta[session_name] = nil
  write_meta(meta)
end

--- Get the default display name: tmux window name if in tmux, else cwd basename.
local function default_display_name()
  if vim.env.TMUX then
    local name = vim.fn.system({ 'tmux', 'display-message', '-p', '#{window_name}' })
    name = vim.trim(name)
    if name ~= '' then
      return name
    end
  end
  return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
end

--- Close neo-tree before writing a session so the special buffer
--- doesn't end up in the session file.
local function close_neotree()
  pcall(function()
    vim.cmd('Neotree close')
  end)
end

--- Temporarily disable nvim's built-in ui2 before session read.
--- mini.sessions runs `%bwipeout!` which triggers LSP on_detach →
--- diagnostic reset → nvim__redraw → nvim_open_win, crashing with
--- E1159 because ui2 tries to open a float while a buffer is closing.
--- Disabling ui2 around the wipeout sidesteps this nightly bug.
local function pre_read()
  pcall(function()
    require('vim._core.ui2').enable({ enable = false })
  end)
end

--- After reading a session: re-trigger filetype detection so plugins
--- (treesitter, LSP, etc.) attach to restored buffers, and show the
--- starter if there are no real buffers.
local function post_read(_session_data)
  -- Defer autocmd re-triggering: mini.sessions fires post_read right after
  -- sourcing the session and wiping old buffers.  Running doautocmd
  -- synchronously here causes diagnostic resets / redraws that collide with
  -- the still-closing buffers (E1159).  vim.schedule lets the event loop
  -- settle first.
  vim.schedule(function()
    -- Re-enable ui2 (disabled in pre_read to avoid E1159)
    pcall(function()
      require('vim._core.ui2').enable({ enable = true })
    end)

    -- Re-trigger BufRead/FileType for all loaded buffers so lazy-loaded
    -- plugins (treesitter, LSP, gitsigns, etc.) attach properly.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd('doautocmd BufReadPost')
          if vim.bo.filetype ~= '' then
            vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
          end
        end)
      end
    end

    -- If the only buffer is an empty unnamed one, show the starter instead
    local bufs = vim.tbl_filter(function(b)
      return vim.api.nvim_buf_is_loaded(b)
        and vim.bo[b].buflisted
        and vim.api.nvim_buf_get_name(b) ~= ''
    end, vim.api.nvim_list_bufs())

    if #bufs == 0 then
      local ok, starter = pcall(require, 'mini.starter')
      if ok then
        starter.open()
      end
    end
  end)
end

--- Auto-restore: on VimEnter, if a session matching the cwd exists
--- in the global sessions directory, read it automatically.
--- Skipped when nvim is opened with files/stdin.
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('mini_sessions_auto_restore', { clear = true }),
  once = true,
  nested = true,
  callback = function()
    if vim.fn.argc() > 0 then
      return
    end

    local ok, sessions = pcall(require, 'mini.sessions')
    if not ok then
      return
    end

    local name = path_to_session_name(vim.fn.getcwd())
    if sessions.detected[name] then
      sessions.read(name)
    end
  end,
})

-- Expose helpers for keymaps and pickers
_G._session_helpers = {
  path_to_session_name = path_to_session_name,
  session_name_to_path = session_name_to_path,
  get_display_name = get_display_name,
  set_display_name = set_display_name,
  has_display_name = has_display_name,
  remove_display_name = remove_display_name,
  default_display_name = default_display_name,
}

return {
  autoread = false,
  autowrite = true,
  directory = session_dir,
  file = '',
  force = { read = false, write = true, delete = false },
  hooks = {
    pre = { read = pre_read, write = close_neotree },
    post = { read = post_read },
  },
  verbose = { read = false, write = true, delete = true },
}
