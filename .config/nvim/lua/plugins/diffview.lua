local M = {}

function M.setup()
  local ok, diff = pcall(require, 'diffview')
  if not ok then return end

  diff.setup({})
end

return M
