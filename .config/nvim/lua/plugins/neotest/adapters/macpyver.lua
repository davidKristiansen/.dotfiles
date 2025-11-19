-- adapter/macpyver.lua
-- SPDX-License-Identifier: MIT

local lib    = require("neotest.lib")
local logger = require("neotest.logging")
local loop   = vim.loop

-- ── tiny utils ────────────────────────────────────────────────────────────────
local function basename(p) return (tostring(p):gsub("[/\\]+$", "")):match("([^/\\]+)$") or p end
local function norm(p) return vim.fs.normalize(p) end
local function real(p) return loop.fs_realpath(norm(p)) or norm(p) end
local function strip_ansi(s) return (s or ""):gsub("\27%[[0-9;]*m", "") end
local function joinpath(a, b) return vim.fs.normalize(a .. "/" .. b) end
local function file_exists(p) return type(p) == "string" and p ~= "" and lib.files.exists(p) end

-- "<num>: <purpose>", trimmed & shortened (mirror pytest plugin behavior)
local function label_for_case(num, purpose)
  purpose = tostring(purpose or ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
  if #purpose > 80 then purpose = purpose:sub(1, 77) .. "..." end
  return string.format("%d: %s", num, purpose)
end

-- shell-like splitter with basic quote handling (' "):
local function split_cmdline(s)
  if type(s) == "table" then return vim.deepcopy(s) end
  local args, buf, q = {}, {}, nil
  for c in tostring(s):gmatch(".") do
    if q then
      if c == q then q = nil else table.insert(buf, c) end
    elseif c == "'" or c == '"' then
      q = c
    elseif c:match("%s") then
      if #buf > 0 then
        table.insert(args, table.concat(buf)); buf = {}
      end
    else
      table.insert(buf, c)
    end
  end
  if #buf > 0 then table.insert(args, table.concat(buf)) end
  return args
end

local function build_env(extra)
  local e = {}
  for k, v in pairs(vim.env) do e[k] = v end
  if extra then for k, v in pairs(extra) do e[k] = v end end
  if not e.PATH or e.PATH == "" then e.PATH = "/usr/local/bin:/usr/bin:/bin" end
  e.PYTHONUNBUFFERED = "1"
  return e
end

-- ── defaults ─────────────────────────────────────────────────────────────────
local default_config = {
  -- REQUIRED launcher prefix, we append subcommands
  cmd             = "uv run --project /Project macpyver",

  -- discovery limits
  include_pattern = nil,
  test_base_path  = nil,
  config          = nil,

  -- execution
  output          = (loop.os_tmpdir() or "/tmp") .. "/neotest_macpyver_" .. loop.hrtime(),

  -- env + timeouts
  env             = nil,
  timeout_ms      = 15000,
}

return function(user_config)
  local cfg = vim.tbl_deep_extend("force", default_config, user_config or {})
  local M   = { name = "neotest-macpyver" }

  -- build commands -------------------------------------------------------------
  local function cmd_query(path)
    local parts = split_cmdline(cfg.cmd)
    vim.list_extend(parts, { "query", "--json" })
    if cfg.test_base_path then
      vim.list_extend(parts, { "--test-base-path", cfg.test_base_path })
    end
    if cfg.config then
      vim.list_extend(parts, { "--config", cfg.config })
    end
    table.insert(parts, path)
    return parts
  end

  local function cmd_exec(target, output_dir)
    local parts = split_cmdline(cfg.cmd)
    vim.list_extend(parts, {
      "run",
      "--progress", "never",
      "--color", "always",
      "--result-output-format", "json",
      "--output", output_dir,
    })
    if cfg.config then
      vim.list_extend(parts, { "--config", cfg.config })
    end
    if cfg.test_base_path then
      vim.list_extend(parts, { "--test-base-path", cfg.test_base_path })
    end
    if target:find("::") then
      local file, case = target:match("^(.+)::(%d+):")
      if file and case then
        vim.list_extend(parts, { "--test-cases", case, "--", file })
      else
        vim.list_extend(parts, { "--", target })
      end
    else
      vim.list_extend(parts, { "--", target })
    end
    return parts
  end

  -- neotest adapter api --------------------------------------------------------
  function M.root(dir)
    return lib.files.match_root_pattern("pyproject.toml", ".git")(dir)
  end

  function M.filter_dir(name)
    return not ({ [".git"] = true, [".venv"] = true, ["__pycache__"] = true, out = true, venv = true })[name]
  end

  function M.is_test_file(p)
    if not (p:sub(-5) == ".yaml" or p:sub(-4) == ".yml") then return false end
    if cfg.include_pattern and not p:find(cfg.include_pattern) then return false end
    return true
  end

  -- DISCOVER via `macpyver query --json`
  function M.discover_positions(path)
    local rp = real(path)
    if not M.is_test_file(rp) then return end

    local cmd = cmd_query(rp)
    local code, result = lib.process.run(cmd, {
      stdout = true,
      stderr = true,
      env = build_env(cfg.env),
      cwd = M.root(path) or loop.cwd(),
    })

    local out = strip_ansi(result.stdout or "")
    if code ~= 0 or not out or out == "" then
      logger.error(("neotest-macpyver: query failed (code=%d) for %s"):format(code, rp))
      return
    end

    local ok, decoded = pcall(vim.json.decode, out)
    if not ok or not decoded then
      logger.error("neotest-macpyver: could not decode JSON from query")
      return
    end

    local specs = (decoded.path and decoded.cases) and { decoded } or decoded
    if type(specs) ~= "table" or #specs == 0 then return end

    local positions = {
      { type = "file", path = rp, name = basename(rp), range = { 0, 0, 99999, 0 } },
    }

    for _, spec in ipairs(specs) do
      local cases = spec.cases or {}
      for i, case in ipairs(cases) do
        local name   = label_for_case(i, case.purpose or "")
        local ln     = tonumber(case.line_no or 1) or 1
        local nodeid = rp .. "::" .. name
        table.insert(positions, {
          type   = "test",
          path   = rp,
          name   = name,
          nodeid = nodeid,
          range  = { math.max(ln - 1, 0), 0, math.max(ln - 1, 0), 1 },
        })
      end
    end

    if #positions == 1 then return end
    return lib.positions.parse_tree(positions)
  end

  -- RUN with macpyver directly
  function M.build_spec(args)
    local data       = args.tree:data()
    local env        = build_env(cfg.env)
    local cwd        = cfg.test_base_path or (M.root(data.path) or loop.cwd())
    local output_dir = (loop.os_tmpdir() or "/tmp") .. "/neotest_macpyver_" .. loop.hrtime()
    local target     = (data.type == "test" and data.nodeid) or data.path
    local cmd        = cmd_exec(target, output_dir)

    return {
      command  = cmd,
      cwd      = cwd,
      env      = env,
      context  = { output_dir = output_dir, target = target, path = data.path },
      strategy = { "integrated" }, -- integrated strategy captures stdout/err to a file
    }
  end

  -- RESULTS (parse JSON output file from macpyver; point output panel to runner stdout/err file)
  function M.results(spec, result, tree)
    local results = {}
    local output_dir = spec.context and spec.context.output_dir
    if not output_dir then return results end

    -- Read JSON file from results.json
    local json_file = joinpath(output_dir, "results.json")
    local ok_r, json_str = pcall(lib.files.read, json_file)
    if not ok_r or not json_str or json_str == "" then
      logger.error("neotest-macpyver: could not read JSON file at " .. json_file)
      return results
    end

    -- Parse JSON
    local ok, decoded = pcall(vim.json.decode, json_str)
    if not ok or not decoded or type(decoded) ~= "table" then
      logger.error("neotest-macpyver: could not decode JSON from macpyver output")
      return results
    end

    -- decoded is an array of test results (or a single object)
    local test_results = decoded
    if test_results.path then test_results = { decoded } end

    -- Path to the integrated strategy's captured stdout/err (if available)
    local runner_output_path = (result and type(result.output) == "string" and file_exists(result.output)) and
        result.output or nil

    for _, test_result in ipairs(test_results) do
      local test_cases = test_result.test_cases or {}

      for i, case in ipairs(test_cases) do
        local status = "skipped"
        if case.status == "PASSED" then
          status = "passed"
        elseif case.status == "FAILED" then
          status = "failed"
        elseif case.status == "SKIPPED" then
          status = "skipped"
        end

        -- Build human summary for the "short" field
        local output_parts = {}
        if case.actions then
          for _, action in ipairs(case.actions) do
            if action.result then
              local prefix = action.fail and "❌ " or "✓ "
              table.insert(output_parts, prefix .. action.result)
            end
          end
        end
        if case.failed_actions and #case.failed_actions > 0 then
          table.insert(output_parts, "\nFailed actions:")
          for _, action in ipairs(case.failed_actions) do
            table.insert(output_parts, string.format("  Line %d: %s", action.line_no or 0, action.result or ""))
          end
        end
        local short_output = table.concat(output_parts, "\n")

        -- Find matching node in tree and attach results
        for _, node in tree:iter_nodes() do
          local d = node:data()
          if d.type == "test" and d.name:match("^" .. i .. ":") then
            results[d.id] = {
              status = status,
              short  = short_output:sub(1, 240),
              output = runner_output_path, -- IMPORTANT: path to stdout/err file; may be nil
              errors = (case.failed_actions and #case.failed_actions > 0) and {
                {
                  message = case.failed_actions[1].result or "Test failed",
                  line    = (case.failed_actions[1].line_no or 1) - 1, -- 0-indexed
                },
              } or nil,
            }
            break
          end
        end
      end
    end

    -- per-file aggregate
    for _, node in tree:iter_nodes() do
      local d = node:data()
      if d.type == "file" and not results[d.id] then
        local any, any_fail, all_pass = false, false, true
        for child in node:iter_nodes() do
          local cd = child:data()
          if cd.type == "test" then
            any = true
            local r = results[cd.id]
            if not r or r.status ~= "passed" then all_pass = false end
            if r and r.status == "failed" then any_fail = true end
          end
        end
        if any then
          results[d.id] = { status = any_fail and "failed" or (all_pass and "passed" or "skipped") }
        end
      end
    end

    -- Clean up macpyver's output dir (safe: runner_output_path is elsewhere)
    pcall(function()
      if vim.uv.fs_stat(output_dir) then
        vim.fn.delete(output_dir, "rf")
      end
    end)

    return results
  end

  return M
end
