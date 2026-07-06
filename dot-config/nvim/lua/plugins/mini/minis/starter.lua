-- SPDX-License-Identifier: MIT
-- lua/plugins/mini/minis/starter.lua
-- Configuration for mini.starter with logo and keybind-consistent actions

--- Resolve the directory to `:cd` into when opening `path` (nil = stay put).
--- Nearest ancestor with a root marker wins. Files already under cwd only
--- ever move cwd *down* into a nested project — never up/out, so a
--- deliberate subdir launch (e.g. dotfiles/dot-config/nvim inside the
--- dotfiles repo) keeps its scope. Files outside cwd fall back to their own
--- directory when no marker is found.
local function cd_target(path)
  local cwd = vim.fn.getcwd()
  local cwd_sep = cwd == '/' and cwd or (cwd .. '/')
  -- Read at call time so runtime overrides of vim.g.root_markers apply.
  -- Nested list = one equal-priority tier: nearest ancestor with ANY marker.
  -- (A flat list would be priority tiers — a far .git would beat a near
  -- pyproject.toml and nested projects would never win.)
  local root = vim.fs.root(path, { vim.g.root_markers or { '.git' } })
  if vim.startswith(path, cwd_sep) then
    if root and root ~= cwd and vim.startswith(root, cwd_sep) then
      return root -- nested project below cwd
    end
    return nil
  end
  return root or vim.fs.dirname(path)
end

--- Build a list of recent file items from v:oldfiles.
--- @param n_files integer  Maximum number of items to return.
--- @param cwd_only boolean Only include files under the current working directory.
local function recent_files(n_files, cwd_only)
  local oldfiles = vim.v.oldfiles
  if #oldfiles == 0 then
    return {}
  end

  local items = {}
  local n_added = 0
  local cwd = vim.fn.getcwd()
  local cwd_with_sep = cwd == '/' and cwd or (cwd .. '/')
  local section = cwd_only and 'Recent files (cwd)' or 'Recent files'

  for _, path in ipairs(oldfiles) do
    -- cwd section: only files under cwd. Global section: only files *outside*
    -- cwd, so the two sections never duplicate each other.
    local under_cwd = vim.startswith(path, cwd_with_sep)
    if
      vim.fn.filereadable(path) == 1
      and vim.fn.isdirectory(path) == 0
      and under_cwd == cwd_only
    then
      -- Name items "filename (dir)" so the typed query matches the filename
      -- first — no need to type through a shared directory prefix. The dir
      -- suffix still disambiguates identical basenames (keep typing: "( ...").
      local dir = vim.fn.fnamemodify(path, cwd_only and ':.:h' or ':~:h')
      local name = vim.fn.fnamemodify(path, ':t') .. (dir ~= '.' and (' (' .. dir .. ')') or '')
      local action = function()
        local target = cd_target(path)
        vim.cmd('bdelete')
        if target then
          vim.cmd.cd(vim.fn.fnameescape(target))
          vim.notify('cwd: ' .. vim.fn.fnamemodify(target, ':~'), vim.log.levels.INFO)
        end
        vim.cmd(('edit %s'):format(vim.fn.fnameescape(path)))
      end
      table.insert(items, { name = name, action = action, section = section })
      n_added = n_added + 1
      if n_added == n_files then
        break
      end
    end
  end

  return items
end

--- @return boolean
local function in_git_repo()
  -- Upward search for a `.git` entry (dir or worktree file) — no subprocess.
  return vim.fs.root(vim.fn.getcwd(), '.git') ~= nil
end

local logo = {
  '░░░░░░░░░░░░░░░░░',
  '░░░▄░▀▄░░░▄▀░▄░░░',
  '░░░█▄███████▄█░░░',
  '░░░███▄███▄███░░░',
  '░░░▀█████████▀░░░',
  '░░░░▄▀░░░░░▀▄░░░░',
  '░░░░░░░░░░░░░░░░░',
}

--- Content hook: strip the "key:" prefix from action items, leaving only the
--- natural label for display.  Query matching still works because mini.starter
--- resolves the prefix from the original item name.
local function hook_strip_action_prefix(content)
  local MiniStarter = require('mini.starter')
  for _, coord in ipairs(MiniStarter.content_coords(content, 'item')) do
    local unit = content[coord.line][coord.unit]
    local key, label = unit.string:match('^(.):(.*)')
    if key and label then
      unit.string = label
      -- Stash the shortcut key and its position in the label so the
      -- MiniStarterOpened autocmd can highlight it later.
      local pos = label:find(key, 1, true) -- plain search
      unit._action_key = key
      unit._action_key_pos = pos -- 1-indexed byte offset, or nil
    end
  end
  return content
end

--- Apply custom highlights to the starter buffer: logo + action shortcut keys.
local function highlight_starter(buf, logo_lines)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local ns = vim.api.nvim_create_namespace('starter_custom_hl')
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- 1) Logo highlight (yellow)
  local first_logo_line = logo_lines[1]:gsub('^%s*', ''):gsub('%s*$', '')
  vim.api.nvim_set_hl(0, 'StarterLogo', { fg = '#d79921' })
  for i, line in ipairs(lines) do
    if line:gsub('^%s*', ''):gsub('%s*$', '') == first_logo_line then
      for j = 0, #logo_lines - 1 do
        local row = i - 1 + j
        if lines[row + 1] then
          vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
            end_row = row,
            end_col = #lines[row + 1],
            hl_group = 'StarterLogo',
          })
        end
      end
      break
    end
  end

  -- 2) Shortcut-key highlight inside action labels.
  --    Walk the rendered content and match each action label in the buffer
  --    to place an extmark on the shortcut letter.
  local MiniStarter = require('mini.starter')
  -- get_content errors on a non-starter buffer; the field-style
  -- `MiniStarter.content` no longer exists in current mini.nvim.
  local ok, content = pcall(MiniStarter.get_content, buf)
  if not ok or not content then
    return
  end

  -- Suppress the default prefix highlight — our StarterActionKey handles it
  -- for action items, and the prefix on file paths is not useful.
  vim.api.nvim_set_hl(0, 'StarterActionKey', { link = 'WarningMsg' })
  vim.api.nvim_set_hl(0, 'StarterFileDir', { link = 'Comment' })
  vim.api.nvim_set_hl(0, 'MiniStarterItemPrefix', { link = 'MiniStarterItem' })
  for _, coord in ipairs(MiniStarter.content_coords(content, 'item')) do
    local unit = content[coord.line][coord.unit]
    -- Compute the byte column: sum of all preceding units on this line
    local col = 0
    for u = 1, coord.unit - 1 do
      col = col + #content[coord.line][u].string
    end
    if unit._action_key_pos then
      local key_col = col + unit._action_key_pos - 1
      vim.api.nvim_buf_set_extmark(buf, ns, coord.line - 1, key_col, {
        end_col = key_col + #unit._action_key,
        hl_group = 'StarterActionKey',
        priority = 200, -- above MiniStarterItemPrefix (52)
      })
    end
    -- Dim the "(dir)" suffix on recent-file items so the filename stands out.
    local base = unit.string:match('^(.*) %(.*%)$')
    if base then
      vim.api.nvim_buf_set_extmark(buf, ns, coord.line - 1, col + #base + 1, {
        end_col = col + #unit.string,
        hl_group = 'StarterFileDir',
        priority = 200,
      })
    end
  end
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniStarterOpened',
  callback = function(args)
    highlight_starter(args.buf or vim.api.nvim_get_current_buf(), logo)
  end,
})

--- Build an action item.  The `key` is the single-char shortcut; `label` is
--- the natural display text (e.g. "git status").  Internally the item name is
--- stored as "key:label" so the shortcut is always the unique query prefix.
--- A content hook later strips the "key:" prefix and highlights the shortcut
--- letter inside the label.
local function action_item(key, label, section, action)
  return { name = key .. ':' .. label, section = section, action = action }
end

return {
  evaluate_single = true,
  header = table.concat(logo, '\n'),
  -- A callable item is evaluated by mini.starter when the start screen is
  -- actually rendered — keeps the oldfiles scan and git check off the
  -- startup path when opening files directly.
  items = {
    function()
      local items = {}

      -- Recent file sections
      vim.list_extend(items, recent_files(5, true))
      vim.list_extend(items, recent_files(3, false))

      -- Quick actions — each item is "key:label".  The key is the shortcut
      -- char (matching the rightmost char of the real keybinding, e.g.
      -- <leader>sf → f).  A content hook below transforms the display so
      -- the label appears as a natural phrase with the shortcut letter
      -- highlighted.  Pickers float on top of the starter; cancel returns
      -- to it.
      table.insert(
        items,
        action_item('f', 'find files', 'Actions', function()
          require('utils.picker').files()
        end)
      )
      table.insert(
        items,
        action_item('g', 'grep', 'Actions', function()
          require('utils.picker').live_grep()
        end)
      )
      table.insert(
        items,
        action_item('o', 'old files', 'Actions', function()
          require('utils.picker').oldfiles()
        end)
      )
      table.insert(
        items,
        action_item('b', 'buffers', 'Actions', function()
          require('utils.picker').buffers()
        end)
      )
      table.insert(
        items,
        action_item('e', 'explorer', 'Actions', function()
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes('<leader>e', true, false, true),
            'm',
            false
          )
        end)
      )
      table.insert(
        items,
        action_item('s', 'sessions', 'Actions', function()
          require('utils.picker').sessions()
        end)
      )
      if in_git_repo() then
        table.insert(
          items,
          action_item('t', 'git status', 'Actions', function()
            require('fzf-lua').git_status()
          end)
        )
      end
      table.insert(items, action_item('q', 'quit', 'Actions', 'qa'))

      return items
    end,
  },
  footer = function()
    return ('Loaded %d modules'):format(#vim.tbl_keys(package.loaded))
  end,
  content_hooks = {
    hook_strip_action_prefix,
    require('mini.starter').gen_hook.aligning('center', 'center'),
    require('mini.starter').gen_hook.padding(3, 2),
  },
}
