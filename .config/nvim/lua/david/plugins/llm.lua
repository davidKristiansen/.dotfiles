return {
  {
    "robitx/gp.nvim",
    event = "VeryLazy",
    opts = {
      -- openai_api_key = {
      --   "op",
      --   "read",
      --   "op://Personal/OPENAI_API_KEY/password",
      --   "--no-newline"
      -- },
      providers = {
        openai = {
          disable = false,
          endpoint = "https://api.openai.com/v1/chat/completions",
          secret = {
            "op",
            "read",
            "op://Personal/OPENAI_API_KEY/password",
            "--no-newline"
          }
        },
      }
    },
  }
}
