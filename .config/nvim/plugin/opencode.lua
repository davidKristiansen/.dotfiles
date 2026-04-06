-- SPDX-License-Identifier: MIT
-- opencode.nvim: AI agent integration (nickjvandyke fork).
-- Loaded on first keymap press (<leader>o*).

local loaded = false

local function load_opencode()
  if loaded then return end
  loaded = true

  ---@type opencode.Opts
  vim.g.opencode_opts = {} -- Must be set before pack.add (plugin reads it on load)

  vim.pack.add({
    { src = 'https://github.com/nickjvandyke/opencode.nvim' },
  }, { confirm = false })

  vim.o.autoread = true -- Required for `opts.events.reload`

  local ok = pcall(require, 'opencode')
  if not ok then return end

  -- Real keymaps (override stubs) — late-bind via require() so functions resolve correctly
  vim.keymap.set({ 'n', 'x' }, '<leader>oa', function() require('opencode').ask('@this: ', { submit = true }) end,
    { desc = 'Ask opencode' })
  vim.keymap.set({ 'n', 'x' }, '<leader>os', function() require('opencode').select() end, { desc = 'Select opencode action' })
  vim.keymap.set({ 'n', 't' }, '<leader>oo', function() require('opencode').toggle() end, { desc = 'Toggle opencode' })
  vim.keymap.set({ 'n', 'x' }, '<leader>or', function() return require('opencode').operator('@this ') end,
    { desc = 'Add range to opencode', expr = true })
  vim.keymap.set('n', '<leader>oR', function() return require('opencode').operator('@this ') .. '_' end,
    { desc = 'Add line to opencode', expr = true })
end

-- Stub keymaps: load on first press, then replay the key
local stubs = {
  { { 'n', 'x' }, '<leader>oa', 'Ask opencode' },
  { { 'n', 'x' }, '<leader>os', 'Select opencode action' },
  { { 'n', 't' }, '<leader>oo', 'Toggle opencode' },
  { { 'n', 'x' }, '<leader>or', 'Add range to opencode' },
  { 'n',          '<leader>oR', 'Add line to opencode' },
}

for _, stub in ipairs(stubs) do
  local modes, lhs, desc
  if type(stub[1]) == 'table' then
    modes, lhs, desc = stub[1], stub[2], stub[3]
  else
    modes, lhs, desc = stub[1], stub[2], stub[3]
  end
  vim.keymap.set(modes, lhs, function()
    load_opencode()
    local keys = vim.api.nvim_replace_termcodes(lhs, true, false, true)
    vim.api.nvim_feedkeys(keys, 'm', false)
  end, { desc = desc })
end
