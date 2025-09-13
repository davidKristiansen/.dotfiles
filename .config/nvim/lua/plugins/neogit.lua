local M = {}

function M.setup()
  local ok, neo = pcall(require, 'neogit')
  if not ok then return end

  neo.setup({
    integrations = {
      diffview = true,  -- Enable Diffview integration
    },
  })
end

return M


