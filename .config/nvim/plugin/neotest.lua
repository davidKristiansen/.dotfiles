-- SPDX-License-Identifier: MIT
-- neotest: test runner (Python, GTest).
-- Loaded on first keymap press (<leader>t*).

local loaded = false

local function load_neotest()
  if loaded then return end
  loaded = true

  vim.pack.add({
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/nvim-neotest/nvim-nio' },
    { src = 'https://github.com/nvim-neotest/neotest' },
    { src = 'https://github.com/nvim-neotest/neotest-python' },
    { src = 'https://github.com/alfaix/neotest-gtest' },

  }, { confirm = false })

  require('neotest').setup({
    discovery = {
      filter_dir = function(name)
        if name:match('^%d%d%-%d%d%-%d%d_') then return false end
        return not ({
          ['.git'] = true, ['.venv'] = true, ['.venv.devcontainer'] = true,
          ['99.Artifacts'] = true, ['bazel-bin'] = true, ['bazel-out'] = true,
          ['bazel-testlogs'] = true, ['bazel-Project'] = true,
          node_modules = true, __pycache__ = true,
        })[name]
      end,
    },
    adapters = {
      (function()
        local ok, gtest = pcall(require, 'neotest-gtest')
        if ok then
          return gtest.setup({
            is_test_file = function(p) if p:find('/build/') then return false end end,
          })
        end
      end)(),
      require('neotest-python')({
        -- Interpreter: rely on the active environment (sourced venv / mise /
        -- direnv). neotest-python auto-detects the interpreter when `python`
        -- is omitted, so we don't hardcode a path here.
        pytest_discover_instances = true,
        args = { '-s', '-v', '-p', 'no:macpyver', '-p', 'no:macpyver_native' },
        is_test_file = function(p)
          if p:find('/build/') then return false end
          if p:find('/99%.Artifacts/') then return false end
          return p:match('/test_.*%.py$') or p:sub(-8) == '_test.py' or p:sub(-7) == 'test_.py'
        end,
      }),
    },
    status       = { virtual_text = false, signs = true },
    output       = { open_on_run = true },
    output_panel = { open = 'botright split | resize 15' },
    signs = {
      enabled = true,
      passed  = '',
      failed  = '',
      running = '',
      skipped = '',
    },
    strategies = {
      integrated = { width = 180, height = 40 },
    },
  })

  local neotest = require('neotest')
  local map = vim.keymap.set

  -- Real keymaps (override stubs)
  map('n', '<leader>ts', function() neotest.summary.toggle() end,                   { desc = 'Neotest: Toggle summary' })
  map('n', '<leader>tr', function() neotest.run.run() end,                           { desc = 'Neotest: Run nearest' })
  map('n', '<leader>tf', function() neotest.run.run(vim.fn.expand('%')) end,          { desc = 'Neotest: Run file' })
  map('n', '<leader>ta', function() neotest.run.run(vim.loop.cwd()) end,             { desc = 'Neotest: Run all (cwd)' })
  map('n', '<leader>tn', function() neotest.jump.next({ status = 'failed' }) end,    { desc = 'Neotest: Next failed' })
  map('n', '<leader>tp', function() neotest.jump.prev({ status = 'failed' }) end,    { desc = 'Neotest: Prev failed' })
  map('n', '<leader>tm', function() neotest.summary.run_marked() end,                { desc = 'Neotest: Run marked' })
  map('n', '<leader>to', function() neotest.output_panel.open() end,                 { desc = 'Neotest: Open output panel' })

  vim.api.nvim_create_autocmd('User', {
    pattern  = 'NeotestRunStarted',
    callback = function() neotest.output_panel.open() end,
  })

  -- Auto-watch test files
  require('plugins.neotest.auto')
end

-- Stub keymaps: load neotest on first press, then replay the key
local stubs = {
  { '<leader>ts', 'Neotest: Toggle summary' },
  { '<leader>tr', 'Neotest: Run nearest' },
  { '<leader>tf', 'Neotest: Run file' },
  { '<leader>ta', 'Neotest: Run all (cwd)' },
  { '<leader>tn', 'Neotest: Next failed' },
  { '<leader>tp', 'Neotest: Prev failed' },
  { '<leader>tm', 'Neotest: Run marked' },
  { '<leader>to', 'Neotest: Open output panel' },
}

for _, stub in ipairs(stubs) do
  local lhs, desc = stub[1], stub[2]
  vim.keymap.set('n', lhs, function()
    load_neotest()
    local keys = vim.api.nvim_replace_termcodes(lhs, true, false, true)
    vim.api.nvim_feedkeys(keys, 'm', false)
  end, { desc = desc })
end
