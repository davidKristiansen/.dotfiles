-- SPDX-License-Identifier: MIT
vim.pack.add({
  { src = "https://github.com/ravitemer/mcphub.nvim" },
  { src = "https://github.com/obsidian-nvim/obsidian-mcp.nvim" },
}, { confirm = false })


require("mcphub").setup()


local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
end

map("n", "<leader>m", "<cmd>MCPHub<CR>", "Mcphub")
