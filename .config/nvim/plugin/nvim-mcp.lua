-- SPDX-License-Identifier: MIT
-- nvim-mcp: MCP server for AI assistant integration (loaded on next tick).

require('utils.lazy').add({
  src = 'https://github.com/linw1995/nvim-mcp',
  config = function()
    require('nvim-mcp').setup({})
  end,
})
