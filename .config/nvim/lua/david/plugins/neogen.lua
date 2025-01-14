return {
  {
    "danymat/neogen",
    config = true,
    keys = {
      { "<leader>cc", ":lua require('neogen').generate()<CR>", desc = "Generate Comment" },
    },
  }
}
