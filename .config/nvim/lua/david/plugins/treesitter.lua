return {
  'nvim-treesitter/nvim-treesitter',
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  opts = {
    sync_install = false,
  }
}
