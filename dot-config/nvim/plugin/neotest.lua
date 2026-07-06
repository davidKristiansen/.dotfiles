-- SPDX-License-Identifier: MIT
-- neotest: test runner (Python, GTest). Keymap-triggered (<leader>t*).

require('utils.lazy').add({
  src = 'https://github.com/nvim-neotest/neotest',
  deps = {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-neotest/nvim-nio',
    'https://github.com/nvim-neotest/neotest-python',
    'https://github.com/alfaix/neotest-gtest',
  },
  config = function()
    require('neotest').setup({
      discovery = {
        filter_dir = function(name)
          if name:match('^%d%d%-%d%d%-%d%d_') then
            return false
          end
          return not ({
            ['.git'] = true,
            ['.venv'] = true,
            ['.venv.devcontainer'] = true,
            ['99.Artifacts'] = true,
            ['bazel-bin'] = true,
            ['bazel-out'] = true,
            ['bazel-testlogs'] = true,
            ['bazel-Project'] = true,
            node_modules = true,
            __pycache__ = true,
          })[name]
        end,
      },
      adapters = {
        (function()
          local ok, gtest = pcall(require, 'neotest-gtest')
          if ok then
            return gtest.setup({
              is_test_file = function(p)
                if p:find('/build/') then
                  return false
                end
              end,
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
            if p:find('/build/') then
              return false
            end
            if p:find('/99%.Artifacts/') then
              return false
            end
            return p:match('/test_.*%.py$') or p:sub(-8) == '_test.py' or p:sub(-7) == 'test_.py'
          end,
        }),
      },
      status = { virtual_text = false, signs = true },
      output = { open_on_run = true },
      output_panel = { open = 'botright split | resize 15' },
      signs = {
        enabled = true,
        passed = '',
        failed = '',
        running = '',
        skipped = '',
      },
      strategies = {
        integrated = { width = 180, height = 40 },
      },
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'NeotestRunStarted',
      callback = function()
        require('neotest').output_panel.open()
      end,
    })

    -- Auto-watch test files
    require('plugins.neotest.auto')
  end,
  keys = {
    {
      '<leader>ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Neotest: Toggle summary',
    },
    {
      '<leader>tr',
      function()
        require('neotest').run.run()
      end,
      desc = 'Neotest: Run nearest',
    },
    {
      '<leader>tf',
      function()
        require('neotest').run.run(vim.fn.expand('%'))
      end,
      desc = 'Neotest: Run file',
    },
    {
      '<leader>ta',
      function()
        require('neotest').run.run(vim.uv.cwd())
      end,
      desc = 'Neotest: Run all (cwd)',
    },
    {
      '<leader>tn',
      function()
        require('neotest').jump.next({ status = 'failed' })
      end,
      desc = 'Neotest: Next failed',
    },
    {
      '<leader>tp',
      function()
        require('neotest').jump.prev({ status = 'failed' })
      end,
      desc = 'Neotest: Prev failed',
    },
    {
      '<leader>tm',
      function()
        require('neotest').summary.run_marked()
      end,
      desc = 'Neotest: Run marked',
    },
    {
      '<leader>to',
      function()
        require('neotest').output_panel.open()
      end,
      desc = 'Neotest: Open output panel',
    },
  },
})
