-- SPDX-License-Identifier: MIT
-- lua/json5_build.lua

vim.pack.add({
  "https://github.com/Joakker/lua-json5",
}, { confirm = false })

vim.cmd("packadd lua-json5")

-- ── helpers ───────────────────────────────────────────────────────────────────
local uv = vim.uv

local function norm(path) return path:gsub("//+", "/") end

local function find_lua_json5_dir()
  local dirs = vim.fn.globpath(vim.o.packpath, "pack/*/*/lua-json5", true, true)
  return (dirs and #dirs > 0) and dirs[1] or nil
end

local function slurp(path)
  local fd = uv.fs_open(path, "r", 438); if not fd then return nil end
  local st = uv.fs_fstat(fd); local data = uv.fs_read(fd, st.size, 0); uv.fs_close(fd)
  return data
end

local function path_exists(p) return p and uv.fs_stat(p) ~= nil end
local function mkdir_p(p) if not path_exists(p) then uv.fs_mkdir(p, 493) end end -- 0755

local function copy_file(src, dst)
  local data = slurp(src); if not data then return false, "read fail" end
  mkdir_p(dst:match("^(.*)/[^/]+$") or ".")
  local fd = uv.fs_open(dst, "w", 420); if not fd then return false, "open fail" end -- 0644
  uv.fs_write(fd, data, 0); uv.fs_close(fd); return true
end

-- Try require('json5'); if missing, we’ll install it properly and try again
local function has_json5()
  local ok = pcall(require, "json5")
  if ok then package.loaded["json5"] = nil end
  return ok
end

-- Build the plugin in-place
local function run_build(dir)
  if not dir then return false, "lua-json5 not found under &packpath" end
  local is_win = vim.loop.os_uname().version:match("Windows")
  local cmd, args
  if is_win then
    cmd, args = "powershell", { "-ExecutionPolicy", "Bypass", "-File", "./install.ps1" }
  else
    cmd, args = "./install.sh", {}
  end
  local res = vim.system({ cmd, unpack(args) }, { cwd = dir, text = true }):wait()
  return res.code == 0, res.stderr ~= "" and res.stderr or res.stdout
end

-- Locate compiled artifact in common places
local function find_artifact(dir)
  local cand = {
    "lua/json5.so",    -- ideal (Linux)
    "lua/json5.dylib", -- ideal (macOS alt)
    "lua/json5.dll",   -- ideal (Windows)
    "json5.so", "json5.dylib", "json5.dll",
    "build/json5.so", "build/json5.dylib", "build/json5.dll",
    "target/release/json5.so", "target/release/libjson5.so",
    "target/release/json5.dylib", "target/release/libjson5.dylib",
    "target/release/json5.dll", "target/release/json5.dll",
  }
  for _, rel in ipairs(cand) do
    local p = norm(dir .. "/" .. rel)
    if path_exists(p) then return p end
  end
  return nil
end

-- Ensure Lua can `require('json5')`
local function ensure_on_cpath(dir, art)
  local lua_dir = norm(dir .. "/lua")
  local suff = art:match("%.([a-zA-Z]+)$") or "so"
  local dst = norm(lua_dir .. "/json5." .. suff)

  -- Prefer copying into <plugin>/lua/json5.*
  if art ~= dst then
    mkdir_p(lua_dir)
    local ok = select(1, copy_file(art, dst))
    if ok and path_exists(dst) then
      return true
    end
  else
    return true
  end

  -- Fallback: extend package.cpath to point at the artifact’s directory
  local dir_of_art = art:match("^(.*)/[^/]+$")
  if dir_of_art and not package.cpath:find(dir_of_art, 1, true) then
    package.cpath = dir_of_art .. "/?.so;" .. dir_of_art .. "/?.dylib;" .. dir_of_art .. "/?.dll;" .. package.cpath
  end
  return true
end

local function ensure_built(silent)
  if has_json5() then
    if not silent then vim.notify("json5 present", vim.log.levels.DEBUG) end
    return
  end

  local dir = find_lua_json5_dir()
  if not dir then
    vim.notify("lua-json5 not found on &packpath", vim.log.levels.ERROR)
    return
  end

  local ok, msg = run_build(dir)
  if not ok then
    vim.notify("lua-json5 build failed: " .. tostring(msg), vim.log.levels.ERROR)
    return
  end

  local art = find_artifact(dir)
  if not art then
    vim.notify("lua-json5 built, but artifact not found", vim.log.levels.ERROR)
    return
  end

  ensure_on_cpath(dir, art)

  package.loaded["json5"] = nil
  local ok2, err = pcall(require, "json5")
  if ok2 then
    vim.notify("lua-json5: ready", vim.log.levels.INFO)
  else
    vim.notify("lua-json5 installed but require failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end

-- 1) Build/load on startup (silent)
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("json5_build_once", { clear = true }),
  callback = function() ensure_built(true) end,
})

-- 2) Manual command
vim.api.nvim_create_user_command("Json5Build", function() ensure_built(false) end, {})

-- 3) Optional: rebuild when packs update (if your setup emits these User events)
pcall(function()
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("json5_pack_changed", { clear = true }),
    pattern = { "PackChanged", "PackUpdated" },
    callback = function()
      local dir = find_lua_json5_dir()
      if dir then ensure_built(true) end
    end,
  })
end)
