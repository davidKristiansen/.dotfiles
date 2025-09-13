-- lua/plugins/luasnip.lua
local function build_jsregexp()
  local ok, fn = pcall(vim.fn.system, { "make", "install_jsregexp" })
  if not ok then
    vim.notify("LuaSnip jsregexp build failed: " .. tostring(fn), vim.log.levels.WARN)
  end
end

local M = {}

function M.setup()
  local ok, ls = pcall(require, "luasnip")
  if not ok then return end

  -- Try to build regex engine if not already present
  local lib = vim.fn.stdpath("data") .. "/site/pack/core/opt/LuaSnip/lib"
  if vim.fn.empty(vim.fn.glob(lib .. "/*jsregexp*")) > 0 then
    vim.schedule(build_jsregexp)
  end

  -- rest of LuaSnip setup …
end

return M

