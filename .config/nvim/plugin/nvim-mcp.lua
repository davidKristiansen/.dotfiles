-- SPDX-License-Identifier: MIT
-- nvim-mcp: MCP server for AI assistant integration with Neovim.

vim.schedule(function()
  vim.pack.add({
    { src = 'https://github.com/linw1995/nvim-mcp' },
  }, { confirm = false })

  local ok, mcp = pcall(require, 'nvim-mcp')
  if not ok then return end
  mcp.setup({})
end)
