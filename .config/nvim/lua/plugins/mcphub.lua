-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, mcp = pcall(require, "mcp")


  if ok then
    mcp.setup()
  end


  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("n", "<leader>m", "<cmd>MCPHub<CR>", "Mcphub")
end

return M
