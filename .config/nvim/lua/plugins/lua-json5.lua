-- SPDX-License-Identifier: MIT
-- lua/json5_build.lua
local M = {}

-- Find plugin dir anywhere under &packpath
local function find_lua_json5_dir()
  local dirs = vim.fn.globpath(vim.o.packpath, "pack/*/*/lua-json5", true, true)
  return (dirs and #dirs > 0) and dirs[1] or nil
end

-- Does the compiled module exist somewhere on runtimepath?
local function has_compiled_json5()
  -- The module loads as 'json5', so rely on package.searchers
  local ok = pcall(require, "json5")
  if ok then
    package.loaded["json5"] = nil -- don’t keep it loaded; we’re just probing
    return true
  end
  return false
end

-- Actually run the build script
local function run_build(dir)
  if not dir then return false, "lua-json5 not found under &packpath" end
  local is_win = vim.loop.os_uname().version:match("Windows")
  local cmd, args
  if is_win then
    cmd = "powershell"
    args = { "-ExecutionPolicy", "Bypass", "-File", "./install.ps1" }
  else
    cmd = "./install.sh"
    args = {}
  end
  local result = vim.system({ cmd, unpack(args) }, { cwd = dir, text = true }):wait()
  local ok = (result.code == 0)
  return ok, ok and "built" or (result.stderr ~= "" and result.stderr or result.stdout)
end

local function ensure_built(silent)
  if has_compiled_json5() then
    if not silent then vim.notify("json5 already built", vim.log.levels.DEBUG) end
    return
  end
  local dir = find_lua_json5_dir()
  local ok, msg = run_build(dir)
  if ok then
    -- Purge & retry require to verify
    package.loaded["json5"] = nil
    local ok2, err = pcall(require, "json5")
    if ok2 then
      vim.notify("lua-json5: build OK", vim.log.levels.INFO)
    else
      vim.notify("lua-json5 built, but require failed: " .. tostring(err), vim.log.levels.WARN)
    end
  else
    vim.notify("lua-json5 build failed: " .. tostring(msg), vim.log.levels.ERROR)
  end
end

function M.setup()
  -- 1) On startup: if not built, build once
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("json5_build_once", { clear = true }),
    callback = function() ensure_built(true) end,
  })

  -- 2) Provide a manual command
  vim.api.nvim_create_user_command("Json5Build", function() ensure_built(false) end, {})

  -- 3) If vim.pack exposes a PackChanged/PackUpdated User event in your build,
  --    hook it (safe-guarded: if it doesn't exist, nothing breaks).
  pcall(function()
    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("json5_pack_changed", { clear = true }),
      pattern = { "PackChanged", "PackUpdated" }, -- whichever your build emits
      callback = function()
        -- Only rebuild if lua-json5 is installed/updated
        local dir = find_lua_json5_dir()
        if dir then ensure_built(true) end
      end,
    })
  end)
end

return M
