-- SPDX-License-Identifier: MIT
local M = {}

-- Find plugin dir anywhere under &packpath
local function find_fzf_native_dir()
  local dirs = vim.fn.globpath(vim.o.packpath, "pack/*/*/telescope-fzf-native.nvim", true, true)
  if not dirs or #dirs == 0 then
    vim.notify("[telescope-fzf-native] Directory not found in packpath.", vim.log.levels.WARN)
    return nil
  end
  return dirs[1]
end

-- Does the compiled module exist?
local function has_compiled()
  local dir = find_fzf_native_dir()
  if not dir then return false end
  -- The compiled library is located in the 'build/' subdirectory.
  return vim.fn.empty(vim.fn.glob(dir .. "/build/libfzf.so")) == 0
end

-- Actually run the build script
local function run_build(dir)
  if not dir then return false, "telescope-fzf-native.nvim not found under &packpath" end
  local result = vim.system({ "make" }, { cwd = dir, text = true }):wait()
  local ok = (result.code == 0)
  return ok, ok and "built" or (result.stderr ~= "" and result.stderr or result.stdout)
end

function M.ensure_built()
  if has_compiled() then
    return
  end
  local dir = find_fzf_native_dir()
  local ok, msg = run_build(dir)
  if ok then
    vim.notify("telescope-fzf-native: build OK", vim.log.levels.INFO)
    pcall(require("telescope").load_extension, "fzf")
  else
    vim.notify("telescope-fzf-native build failed: " .. tostring(msg), vim.log.levels.ERROR)
  end
end

return M
