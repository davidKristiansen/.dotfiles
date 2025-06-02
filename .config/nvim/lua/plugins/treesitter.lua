-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      sync_install = false,
      ensure_installed = {
        "python",
        "c",
        "bash",
        "lua",
        "markdown",
        "markdown_inline",
        "yaml",
        "html",
        "bibtex",
        "latex",
      },
      auto_install = true,
      highlight = { enable = true },
    })
  end,
}
