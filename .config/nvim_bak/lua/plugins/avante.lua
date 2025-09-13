return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "saghen/blink.cmp",
    "Kaiser-Yang/blink-cmp-avante",
    "ibhagwan/fzf-lua",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("avante").setup({
      override_prompt_dir = vim.fn.expand("~/.config/nvim/avante_prompts"),
      provider = "openai",
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4.1",
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_completion_tokens = 8192,
          },
        },
      },
    })
  end,
}
