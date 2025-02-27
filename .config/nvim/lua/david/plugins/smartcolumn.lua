return {
  {
    "m4xshen/smartcolumn.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      disabled_filetypes = { "help", "text" },
      colorcolumn = "80",
    }
  },
}
