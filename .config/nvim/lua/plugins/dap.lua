-- lua/plugins/dap.lua
-- SPDX-License-Identifier: MIT
-- Bare-bones Python debugging via nvim-dap + nvim-dap-python, tuned for uv.

vim.pack.add({
  "https://github.com/Joakker/lua-json5",
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/mfussenegger/nvim-dap-python" },
  { src = "https://github.com/igorlfs/nvim-dap-view" },
}, { confirm = false })


require("dap-view").setup()

local dap = require("dap")

-- ── Python host detection ─────────────────────────────────────────────────────
-- Prefer venv if it exists in the current project, otherwise use system python
local cwd = vim.fn.getcwd()
local venv_python = cwd .. "/.venv/bin/python"
local python_host = vim.fn.executable(venv_python) == 1 and venv_python or vim.fn.exepath("python")

require("dap-python").setup(python_host)

-- ── launch.json loader (silent, relaxed JSON) ─────────────────────────────────
local function read_file(path)
  local fd = vim.uv.fs_open(path, "r", 438)
  if not fd then return nil end
  local st = vim.uv.fs_fstat(fd)
  local data = vim.uv.fs_read(fd, st.size, 0)
  vim.uv.fs_close(fd)
  return data
end

local function load_launchjs(path, adapters)
  local file = path or (vim.fn.getcwd() .. "/.vscode/launch.json")
  if not vim.uv.fs_stat(file) then return end
  local raw = read_file(file)
  if not raw then return end
  local ok, cfg = pcall(require("json5").parse, raw)
  if not ok or type(cfg) ~= "table" then return end

  adapters = adapters or { python = { "python" } }
  local confs = cfg.configurations or {}
  for _, c in ipairs(confs) do
    if type(c) == "table" and c.type then
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

load_launchjs(nil, { python = { "python" } })

-- ── Default configs ──────────────────────────────────────────────────────────
local cwd = vim.fn.getcwd()
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Python: Current file",
    program = "${file}",
    pythonPath = python_host,
    pythonArgs = { "-m", "debugpy.adapter" },
    env = { PYTHONPATH = cwd .. "/src" },
    console = "integratedTerminal",
    justMyCode = false,
  },
  {
    type = "python",
    request = "attach",
    name = "Attach: Pick process",
    processId = require("dap.utils").pick_process,
    pythonPath = python_host,
    env = { PYTHONPATH = cwd .. "/src" },
    justMyCode = false,
  },
}

-- ── UI bits ──────────────────────────────────────────────────────────────────
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointRejected", { text = "⊘", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo" })

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = "DAP: " .. desc })
end
map("<F5>", dap.continue, "Continue")
map("<leader>dc", dap.continue, "Continue")
map("<leader>ds", dap.step_over, "Step Over")
map("<leader>di", dap.step_into, "Step Into")
map("<leader>do", dap.step_out, "Step Out")
map("<leader>db", dap.toggle_breakpoint, "Toggle Breakpoint")
map("<leader>dT", dap.terminate, "Terminate")
map("<leader>dw", "<cmd>DapViewWatch<cr>", "Watch")
map("<leader>du", "<cmd>DapViewToggle<cr>", "Watch")

vim.api.nvim_create_user_command("DapPYHere", function()
  dap.run(dap.configurations.python[1])
end, { desc = "Run current Python file" })
