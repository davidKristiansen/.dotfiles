-- SPDX-License-Identifier: MIT
-- opencode.nvim (sudo-tee): Neovim frontend for opencode AI agent.
-- Loaded via vim.schedule.

vim.schedule(function()
  vim.pack.add({
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/sudo-tee/opencode.nvim' },
  }, { confirm = false })

  local ok, opencode = pcall(require, 'opencode')
  if not ok then return end

  opencode.setup({
    keymap_prefix = '<leader>a',
    preferred_picker = 'fzf',
    preferred_completion = 'blink',
    keymap = {
      input_window = {
        ['<S-cr>'] = false,
        ['<cr>'] = { 'submit_input_prompt', mode = { 'n', 'i' } },
      },
    },
    ui = {
      position = 'right',
      window_width = 0.40,
      icons = { preset = 'nerdfonts' },
    },
  })
end)
