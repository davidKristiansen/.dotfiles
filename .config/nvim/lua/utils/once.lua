-- SPDX-License-Identifier: MIT
-- Utility module to ensure certain functions only run once per session.
-- Useful for one-time setup code (e.g. TSUpdate, first-run migrations, etc.)

local M = {}

--- Run a function once per session, keyed by a unique string.
-- @param key string  Identifier for this one-time action
-- @param fn  function Function to execute (wrapped in pcall for safety)
function M.run(key, fn)
  -- Construct a global guard variable name (e.g. "__once_ts_update")
  local gkey = ("__once_%s"):format(key)

  -- If the guard is already set, skip running the function
  if vim.g[gkey] then return end

  -- Mark this key as "done" in the global scope
  vim.g[gkey] = true

  -- Safely execute the function (no error propagation if fn fails)
  pcall(fn)
end

return M

