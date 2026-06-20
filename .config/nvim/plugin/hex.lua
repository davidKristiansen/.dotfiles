vim.schedule(function()
  vim.pack.add({
    { src = 'https://github.com/RaafatTurki/hex.nvim' },
  }, { confirm = false })

  local ok, hex = pcall(require, 'hex')
  if not ok then return end

  hex.setup()

  -- Under the <leader>T toggles group (<leader>h is the start screen).
  vim.keymap.set('n', '<leader>Tx', function() hex.toggle() end, { desc = 'Toggle hex view' })
end)
