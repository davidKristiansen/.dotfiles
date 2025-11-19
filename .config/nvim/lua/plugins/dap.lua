-- lua/plugins/dap.lua
-- SPDX-License-Identifier: MIT
-- Bare-bones Python debugging via nvim-dap + nvim-dap-python, tuned for uv.

vim.pack.add({
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/mfussenegger/nvim-dap-python" },
  { src = "https://github.com/igorlfs/nvim-dap-view" },
}, { confirm = false })


require("dap-view").setup()

local dap = require("dap")

-- ── Python host detection ─────────────────────────────────────────────────────
local function path_exists(p)
  return p and vim.uv.fs_stat(p) ~= nil
end

local function py_in(venv)
  return venv .. "/bin/python"
end

local function ensure_uv_debugpy()
  local cwd = vim.fn.getcwd()
  local venv = cwd .. "/.venv"
  local py = py_in(venv)
  if not path_exists(venv) then
    vim.system({ "uv", "venv", ".venv" }):wait()
  end
  if vim.system({ py, "-c", "import debugpy" }):wait().code ~= 0 then
    vim.system({ "uv", "pip", "install", "debugpy" }):wait()
  end
  return py
end

local function detect_python()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and path_exists(venv .. "/bin/python") then
    return venv .. "/bin/python"
  end
  if path_exists(vim.fn.getcwd() .. "/.venv/bin/python") then
    return py_in(vim.fn.getcwd() .. "/.venv")
  end
  return ensure_uv_debugpy()
end

local python_host = detect_python()

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

local function relax_json(s)
  s = s:gsub("/%*.-%*/", "")
  s = s:gsub("[ \t]*//[^\n]*", "")
  s = s:gsub(",%s*([}%]])", "%1")
  return s
end

local function load_launchjs(path, adapters)
  local file = path or (vim.fn.getcwd() .. "/.vscode/launch.json")
  if not vim.uv.fs_stat(file) then return end
  local raw = read_file(file)
  if not raw then return end
  local ok, cfg = pcall(vim.json.decode, relax_json(raw))
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
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Python: Current file",
    program = "${file}",
    pythonPath = python_host,
    console = "integratedTerminal",
    justMyCode = false,
  },
  {
    type = "python",
    request = "attach",
    name = "Attach: Pick process",
    processId = require("dap.utils").pick_process,
    pythonPath = python_host,
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
map("<F10>", dap.step_over, "Step Over")
map("<F11>", dap.step_into, "Step Into")
map("<S-F11>", dap.step_out, "Step Out")
map("<leader>db", dap.toggle_breakpoint, "Toggle Breakpoint")

vim.api.nvim_create_user_command("DapPYHere", function()
  dap.run(dap.configurations.python[1])
end, { desc = "Run current Python file" })
