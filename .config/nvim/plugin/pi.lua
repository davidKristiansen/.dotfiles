-- SPDX-License-Identifier: MIT
-- pi-nvim: Bridge between pi coding agent and Neovim.
-- Sends files, selections, and prompts from Neovim to a running pi session.
-- Loaded via vim.schedule.

vim.schedule(function()
  vim.pack.add({
    { src = 'https://github.com/carderne/pi-nvim' },
  }, { confirm = false })

  local ok, pi = pcall(require, 'pi-nvim')
  if not ok then return end

  pi.setup()
end)
