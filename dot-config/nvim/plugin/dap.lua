-- SPDX-License-Identifier: MIT
-- nvim-dap: debugging (Python + GTest). Keymap-triggered (<F5>, <leader>d*).

require('utils.lazy').add({
  src = 'https://github.com/mfussenegger/nvim-dap',
  deps = {
    'https://github.com/Joakker/lua-json5',
    'https://github.com/mfussenegger/nvim-dap-python',
    'https://github.com/igorlfs/nvim-dap-view',
  },
  config = function()
    require('dap-view').setup()

    local dap = require('dap')

    -- Python host: rely on the active environment (sourced venv / mise / direnv).
    -- Fall back to a project-local .venv only if nothing is on PATH.
    local cwd = vim.fn.getcwd()
    local python_host = vim.fn.exepath('python3')
    if python_host == '' then python_host = vim.fn.exepath('python') end
    if python_host == '' then python_host = cwd .. '/.venv/bin/python' end

    require('dap-python').setup(python_host)

    -- launch.json loader (silent, relaxed JSON)
    local function read_file(path)
      local fd = vim.uv.fs_open(path, 'r', 438)
      if not fd then return nil end
      local st = vim.uv.fs_fstat(fd)
      local data = vim.uv.fs_read(fd, st.size, 0)
      vim.uv.fs_close(fd)
      return data
    end

    local function load_launchjs(path, adapters)
      local file = path or (vim.fn.getcwd() .. '/.vscode/launch.json')
      if not vim.uv.fs_stat(file) then return end
      local raw = read_file(file)
      if not raw then return end
      local ok, cfg = pcall(require('json5').parse, raw)
      if not ok or type(cfg) ~= 'table' then return end

      adapters = adapters or { python = { 'python' } }
      local confs = cfg.configurations or {}
      for _, c in ipairs(confs) do
        if type(c) == 'table' and c.type then
          local langs = adapters[c.type]
          if langs then
            for _, lang in ipairs(langs) do
              dap.configurations[lang] = dap.configurations[lang] or {}
              table.insert(dap.configurations[lang], c)
            end
          end
        end
      end
    end

    load_launchjs(nil, { python = { 'python' } })

    -- Default configs
    dap.configurations.python = {
      {
        type       = 'python',
        request    = 'launch',
        name       = 'Python: Current file',
        program    = '${file}',
        pythonPath = python_host,
        pythonArgs = { '-m', 'debugpy.adapter' },
        env        = { PYTHONPATH = cwd .. '/src' },
        console    = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type       = 'python',
        request    = 'attach',
        name       = 'Attach: Pick process',
        processId  = require('dap.utils').pick_process,
        pythonPath = python_host,
        env        = { PYTHONPATH = cwd .. '/src' },
        justMyCode = false,
      },
    }

    -- UI bits
    vim.fn.sign_define('DapBreakpoint',         { text = '', texthl = 'DiagnosticError' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticWarn' })
    vim.fn.sign_define('DapStopped',            { text = '', texthl = 'DiagnosticInfo' })

    vim.api.nvim_create_user_command('DapPYHere', function()
      dap.run(dap.configurations.python[1])
    end, { desc = 'Run current Python file' })
  end,
  keys = {
    { '<F5>',       function() require('dap').continue() end,          desc = 'DAP: Continue' },
    { '<leader>dc', function() require('dap').continue() end,          desc = 'DAP: Continue' },
    { '<leader>ds', function() require('dap').step_over() end,         desc = 'DAP: Step Over' },
    { '<leader>di', function() require('dap').step_into() end,         desc = 'DAP: Step Into' },
    { '<leader>do', function() require('dap').step_out() end,          desc = 'DAP: Step Out' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'DAP: Toggle Breakpoint' },
    { '<leader>dT', function() require('dap').terminate() end,         desc = 'DAP: Terminate' },
    { '<leader>dw', '<cmd>DapViewWatch<cr>',                           desc = 'DAP: Watch' },
    { '<leader>du', '<cmd>DapViewToggle<cr>',                          desc = 'DAP: Toggle View' },
  },
})
